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

    global_game_state = Game_State {
        camera = {
            zoom = 1,
            offset = {f32(rl.GetScreenWidth())/2, f32(rl.GetScreenHeight())/2},
        },
        helper_activated = false,
        current_menu = .Pause,
        create_hit_particle = create_hit_particles
    }
    sync_menu(&global_game_state)
    get_tooltips(&global_game_state.tooltips, map_allocator)

    cooldown := ui.UI_Cooldown{
        pos = {550, f32(rl.GetScreenHeight() - 100)},
        width = 64,
        height = 64,
        icon = rl.LoadTexture("assets/igel.png")
    }
    

    // append(&game.ui_elements, p_bar)

    defer{
        
        delete(global_game_state.current_level.player_bullets)
        delete(global_game_state.current_level.enemy_bullets)
        delete(global_game_state.current_level.enemy_fragments)
        delete(global_game_state.current_level.loot)
        delete(global_game_state.current_level.upgrade_pool)
        delete(global_game_state.current_level.available_upgrades)
        delete(global_game_state.current_level.particles)
        delete(global_game_state.current_level.level_visual.tilesets)
        delete(global_game_state.current_level.level_visual.layers)
        delete(global_game_state.current_level.ui_elements)

        delete(global_game_state.level_data)
        delete(global_game_state.menu.elements)
        delete(global_game_state.player.statuses)
        delete(global_game_state.player.weapon.bullet.applied_status)
        for &e in global_game_state.current_level.enemies{
            delete(e.statuses)
        }
        for &s in global_game_state.current_level.spawner{
            delete(s.enemy.applied_status)
        }
        delete(global_game_state.current_level.enemies)
        delete(global_game_state.current_level.spawner)
        for &element in global_game_state.current_level.ui_elements{
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
    level_visual, ok := m.load_map("assets/test_map.json", map_allocator)
    if ok{
        global_game_state.player = create_player()
        global_game_state.player.pos = m.get_player_spawn_pos(level_visual)
        global_game_state.camera.target = global_game_state.player.pos
        level := create_start_level()
        level.level_visual = level_visual

        spawner := create_spawner(1, 1, 1, 500)
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

        append(&global_game_state.level_data, level)

        status = create_poison_status()
        // append(&game.player.statuses, status)
        append(&global_game_state.player.weapon.bullet.applied_status, status)
        status = create_fire_status()
        append(&global_game_state.player.weapon.bullet.applied_status, status)

        global_game_state.current_level = level
        level_up_spawner_update(&global_game_state)
        
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
        v_bar.rect.x += p_bar.rect.width + 100
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
        global_game_state.player.ability = ability_test
        global_game_state.player.ability_cd = ability_cd
        get_upgrade_target(&global_game_state.player)
        create_upgrades(&global_game_state.current_level.upgrade_pool)
        fill_available_upgrades(&global_game_state)
        global_game_state.player.h_bar = p_bar
        global_game_state.player.v_bar = v_bar

        pos : rl.Vector2 = {p_bar.rect.x, p_bar.rect.y - 25}
        status_bar := ui.create_ui_status_bar(pos)

        append(&global_game_state.current_level.ui_elements, cooldown)
        append(&global_game_state.current_level.ui_elements, global_game_state.player.h_bar)
        append(&global_game_state.current_level.ui_elements, global_game_state.player.v_bar)
        append(&global_game_state.current_level.ui_elements, status_bar)
    } else{
        panic("Could not load the level!")
    }
    for !rl.WindowShouldClose(){
        dt :=  rl.GetFrameTime()
        update_camera(&global_game_state, dt)
        update_game(&global_game_state, dt)
        check_collisions(&global_game_state)
        //game.camera.target += handler.get_camera_follow_pos(game.player.pos, game.camera, dt)
        
        draw_game(global_game_state)

        if global_game_state.should_close{
            break
        }
    }
}

update_game :: proc(g : ^Game_State, dt : f32) {
    update_helper(g)
    update_handler(g, dt)
    if !g.is_paused && !g.current_level.power_level_up{
        g.play_time += dt
        update_player(g, dt)
        update_player_shooting(g, dt)
        update_player_bullets(g, dt)
        update_enemy_bullets(g, dt)
        update_player_casting(g, dt)
        update_spawner(g, dt)
        update_enemy(g, dt)
        update_fragement(g, dt)
        update_loot(g, dt)
        update_particle(g, dt)
        update_in_game_ui(g, dt)
    } else if g.current_level.power_level_up{
        update_upgrade(g, dt)
    } else{
        update_menu(g)
    }
}

check_collisions :: proc(g : ^Game_State){
    if !g.is_paused && !g.current_level.power_level_up{
        check_enemy_player(g)
        check_bullet(g)
        check_bullet_player(g)
        check_collisions_detection_loot(g)
        check_collisions_pickup_loot(g)
        check_in_game_ui()
    } else if g.current_level.power_level_up{
        check_collision_upgrade_slot(g)
    } else{
        check_collision_menu(g)
    }
}

draw_game :: proc(g : Game_State){
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLUE)
    rl.BeginMode2D(g.camera)
    if g.map_drawing{
        draw_map(g)
    }
    draw_fragments(g)
    draw_player(g)
    draw_loot(g)
    draw_bullet(g)
    draw_enemies(g)
    draw_particles(g)
    rl.EndMode2D()
    draw_in_game_ui(g)
    if g.is_paused{
        draw_menu(g)
    } else if g.current_level.power_level_up{
        draw_upgrade(g)
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

check_which_btn_was_pressed :: proc(g : ^Game_State, b : ^ui.UI_Button){
    b.state = .None
    switch b.type{
        case .Continue:
            on_click_continue(g)
        case .Options:
            on_click_options(g)
        case .Back:
            on_click_back(g)
        case .Exit:
            on_click_quit(g)
    }
}

sync_menu :: proc(g : ^Game_State){
    clear(&g.menu.elements)
    switch g.current_menu{
        case .Pause:
            width : f32 = 500
            height : f32 = 100
            pos_x := f32(rl.GetScreenWidth()) / 2 - width/2
            pos_y := f32(rl.GetScreenHeight()) * 0.25
            btn := ui.create_button("Continue", {pos_x, pos_y}, {width, height})
            btn.type = .Continue
            append(&g.menu.elements, btn)
            pos_y += btn.height * 2 + 50 
            btn = ui.create_button("Options", {pos_x, pos_y}, {width, height})
            btn.type = .Options
            append(&g.menu.elements, btn)
            pos_y += btn.height * 2 + 50 
            btn = ui.create_button("Exit", {pos_x, pos_y}, {width, height})
            btn.type = .Exit
            append(&g.menu.elements, btn)
        case .Options:
            width : f32 = 500
            height : f32 = 100
            pos_x := f32(rl.GetScreenWidth()) / 2 - width /2
            pos_y := f32(rl.GetScreenHeight()) * 0.85
            btn := ui.create_button("Back", {pos_x, pos_y}, {width, height})
            btn.type = .Back
            append(&g.menu.elements, btn)

            label := ui.create_label("Test:", {100, 100}, {500, 100})
            append(&g.menu.elements, label)

            slider := ui.create_slider({700, 100}, {1000, 100})
            append(&g.menu.elements, slider)
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