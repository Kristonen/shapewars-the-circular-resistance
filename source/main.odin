package game

import "core:mem/virtual"
import "core:strings"
import rl "vendor:raylib"
import "core:fmt"
import "core:mem"
import cl "collider"
import m "map"
import "ui"
import "handler"
import "loot"

//////////////////////////////////////////////////////
//   Project to learn the odin programming language //
//////////////////////////////////////////////////////

main :: proc(){
    
    rl.InitWindow(1920, 1080, "Shapewars: The Circular Resistance")
    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.SetTargetFPS(500)

    track : mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    arena : virtual.Arena
    err := virtual.arena_init_growing(&arena)
    map_allocator := virtual.arena_allocator(&arena)

    defer{
        for _, entry in track.allocation_map{
            fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
        }
        for entry in track.bad_free_array{
            fmt.eprintf("%v bad free\n", entry.location)
        }
        mem.tracking_allocator_destroy(&track)
        virtual.arena_free_all(&arena)
    }

    game = Game_State {
        camera = {
            zoom = 1,
            offset = {f32(rl.GetScreenWidth())/2, f32(rl.GetScreenHeight())/2},
        },
        helper_activated = false,
        current_menu = .Pause,
        create_hit_particle = create_hit_particles
    }
    sync_menu()

    cooldown := ui.UI_Cooldown{
        rec = {
            x = 550,
            y = f32(rl.GetScreenHeight() - 100),
            width = 64,
            height = 64,
        },
        icon = rl.LoadTexture("assets/igel.png")
    }
    

    // append(&game.ui_elements, p_bar)

    defer{
        
        delete(game.current_level.player_bullets)
        delete(game.current_level.enemy_bullets)
        delete(game.current_level.enemy_fragments)
        delete(game.current_level.loot)
        delete(game.current_level.upgrade_pool)
        delete(game.current_level.available_upgrades)
        delete(game.current_level.particles)
        delete(game.current_level.level_visual.tilesets)
        delete(game.current_level.level_visual.layers)
        delete(game.current_level.ui_elements)

        delete(game.level_data)
        delete(game.menu.elements)
        delete(game.player.statuses)
        delete(game.player.weapon.bullet.applied_status)
        for &e in game.current_level.enemies{
            delete(e.statuses)
        }
        for &s in game.current_level.spawner{
            delete(s.enemy.applied_status)
        }
        delete(game.current_level.enemies)
        delete(game.current_level.spawner)
        delete(game.tooltips)
        for &element in game.current_level.ui_elements{
            switch &e in &element{
                case ui.UI_Cooldown:
                case ui.UI_Button:
                case ui.UI_Menu:
                case ui.UI_Progress_Bar:
                case ui.UI_Label:
                case ui.UI_Slider:
                case ui.UI_Status_Bar:
                    delete(e.slots)
            }
        }
        rl.CloseWindow()
    }
    
    if tooltips, ok := get_tooltips(map_allocator); ok{
        game.tooltips = tooltips
    }
    
    if level_visual, ok := m.load_map("assets/test_map.json", map_allocator); ok{
        game.player = create_player()
        game.player.pos = m.get_player_spawn_pos(level_visual)
        game.camera.target = game.player.pos
        level := create_start_level()
        level.level_visual = level_visual

        spawner := create_spawner(1, 1, 1, 1)
        spawner.enemy = create_start_enemy({width = 48, height = 32, x = 0, y = 0}, 200, rl.RED)
        append(&level.spawner, spawner)

        spawner = create_spawner(2, 2, 1, 500)
        spawner.enemy = create_second_enemy()
        append(&level.spawner, spawner)

        spawner = create_spawner(1, 1, 1, 500)
        spawner.enemy = create_third_enemy()
        append(&level.spawner, spawner)

        spawner = create_spawner(10, 0.1, 0)
        spawner.enemy = create_dummy_enemy()
        status := create_poison_status()
        status.strength = 0.2
        append(&spawner.enemy.applied_status, status)
        status = create_fire_status()
        status.strength = 0.2
        append(&spawner.enemy.applied_status, status)
        append(&level.spawner, spawner)

        append(&game.level_data, level)

        status = create_poison_status()
        // append(&game.player.statuses, status)
        append(&game.player.weapon.bullet.applied_status, status)
        status = create_fire_status()
        append(&game.player.weapon.bullet.applied_status, status)

        game.current_level = level
        level_up_spawner_update()
        
        rect := rl.Rectangle {
            x = 50,
            y = f32(rl.GetScreenHeight() - 100),
            width = f32(rl.GetScreenWidth()) * 0.25,
            height = 50,
        }
        p_bar := ui.create_progress_bar(rect, rl.BLACK, rl.GRAY, rl.RED)
        p_bar.show_text = true
        p_bar.min = 0
        p_bar.type = .Health

        v_bar := p_bar
        v_bar.rec.x += p_bar.rec.width + 100
        v_bar.fill_color = rl.BLUE
        v_bar.type = .Value

        ability_test := Radial_Liberation{   
            count = 8,
            damage = 5,
        }
        // ability_test := ab.Dash{

        // }
        ability_cd := Ability_Cooldown{
            cast_rate = 5,
        }
        //TODO -> Make ability cd part of the ability instead of player
        game.player.ability = ability_test
        game.player.ability_cd = ability_cd
        get_upgrade_target(&game.player)
        create_upgrades(&game.current_level.upgrade_pool)
        fill_available_upgrades(&game)
        game.player.h_bar = p_bar
        game.player.v_bar = v_bar

        pos : rl.Vector2 = {p_bar.rec.x, p_bar.rec.y - 25}
        status_bar := ui.create_ui_status_bar(pos)

        append(&game.current_level.ui_elements, cooldown)
        append(&game.current_level.ui_elements, game.player.h_bar)
        append(&game.current_level.ui_elements, game.player.v_bar)
        append(&game.current_level.ui_elements, status_bar)
    } else{
        panic("Could not load the level!")
    }
    for !rl.WindowShouldClose(){
        dt :=  rl.GetFrameTime()
        update_camera(dt)
        check_collisions()
        update_game(dt)
        draw_game()

        if game.should_close{
            //break
        }
    }
}

update_game :: proc(dt : f32) {
    update_helper()
    update_handler(dt)
    if !game.is_paused && !game.current_level.power_level_up{
        game.play_time += dt
        update_player(dt)
        update_player_shooting(dt)
        update_player_bullets(dt)
        update_enemy_bullets(dt)
        update_player_casting(dt)
        update_spawner(dt)
        update_enemy(dt)
        update_fragement(dt)
        update_loot(dt)
        update_particle(dt)
        update_in_game_ui(dt)
        update_tooltip(dt)
    } else if game.current_level.power_level_up{
        update_upgrade(dt)
    } else{
        update_menu()
    }
}

check_collisions :: proc(){
    if !game.is_paused && !game.current_level.power_level_up{
        check_enemy_player()
        check_bullet()
        check_bullet_player()
        check_collisions_detection_loot()
        check_collisions_pickup_loot()
        check_in_game_ui_tooltip()
    } else if game.current_level.power_level_up{
        check_collision_upgrade_slot()
    } else{
        check_collision_menu()
    }
}

draw_game :: proc(){
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLUE)
    rl.BeginMode2D(game.camera)
    if game.map_drawing{
        draw_map()
    }
    draw_fragments()
    draw_player()
    draw_loot()
    draw_bullet()
    draw_enemies()
    draw_particles()
    rl.EndMode2D()
    draw_in_game_ui()
    draw_tooltip()
    if game.is_paused{
        draw_menu()
    } else if game.current_level.power_level_up{
        draw_upgrade()
    }
    rl.EndDrawing()
}

cast_ability :: proc(g : ^Game_State){
    switch &a in g.player.ability{
        case Radial_Liberation:
            cast_radial_liberation(a, &g.current_level.player_bullets, g.player.pos)
        case Dash:

    }
}

check_which_btn_was_pressed :: proc(b : ^ui.UI_Button){
    b.state = .None
    switch b.type{
        case .Continue:
            on_click_continue()
        case .Options:
            on_click_options()
        case .Back:
            on_click_back()
        case .Exit:
            on_click_quit()
    }
}

sync_menu :: proc(){
    clear(&game.menu.elements)
    switch game.current_menu{
        case .Pause:
            width : f32 = 500
            height : f32 = 100
            pos_x := f32(rl.GetScreenWidth()) / 2 - width/2
            pos_y := f32(rl.GetScreenHeight()) * 0.25
            btn := ui.create_button("Continue", {pos_x, pos_y}, {width, height})
            btn.type = .Continue
            append(&game.menu.elements, btn)
            pos_y += btn.rec.height * 2 + 50 
            btn = ui.create_button("Options", {pos_x, pos_y}, {width, height})
            btn.type = .Options
            append(&game.menu.elements, btn)
            pos_y += btn.rec.height * 2 + 50 
            btn = ui.create_button("Exit", {pos_x, pos_y}, {width, height})
            btn.type = .Exit
            append(&game.menu.elements, btn)
        case .Options:
            width : f32 = 500
            height : f32 = 100
            pos_x := f32(rl.GetScreenWidth()) / 2 - width /2
            pos_y := f32(rl.GetScreenHeight()) * 0.85
            btn := ui.create_button("Back", {pos_x, pos_y}, {width, height})
            btn.type = .Back
            append(&game.menu.elements, btn)

            label := ui.create_label("Test:", {100, 100}, {500, 100})
            append(&game.menu.elements, label)

            slider := ui.create_slider({700, 100}, {1000, 100})
            append(&game.menu.elements, slider)
        case.Main:
    }
}

fill_available_upgrades :: proc(g : ^Game_State){
    common : i32
    uncommon : i32
    rare : i32
    epic : i32
    legendary : i32
    for u in g.current_level.upgrade_pool{
        if u.target == .Player{
            append(&g.current_level.available_upgrades, u)
        } else if g.player.target_ability == u.target{
            append(&g.current_level.available_upgrades, u)
        }
        switch u.rarity{
            case .Common: common += 1
            case .Uncommon: uncommon += 1
            case .Rare: rare += 1
            case .Epic: epic += 1
            case .Legendary: legendary += 1
        }
    }
    fmt.printfln("Common: %i", common)
    fmt.printfln("Uncommon: %i", uncommon)
    fmt.printfln("Rare: %i", rare)
    fmt.printfln("Epic: %i", epic)
    fmt.printfln("Legendary: %i", legendary)
}