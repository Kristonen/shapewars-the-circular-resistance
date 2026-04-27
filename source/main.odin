package game

import "core:reflect"
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
    rl.SetExitKey(.KEY_NULL)
    // rl.SetMouseCursor(.CROSSHAIR)

    track : mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    arena : virtual.Arena
    err := virtual.arena_init_growing(&arena)
    map_allocator := virtual.arena_allocator(&arena)
    game.map_allocator = map_allocator
    game.arena = arena

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
        create_hit_particle = create_hit_particles,
        current_level = .HQ,
        skill_points = 100,
    }
    for idx in 0..<len(Level_Type){
        type := Level_Type(idx)
        append(&game.levels, type)
    }
    sync_menu()

    // cooldown := ui.UI_Cooldown{
    //     rec = {
    //         x = 550,
    //         y = f32(rl.GetScreenHeight() - 100),
    //         width = 64,
    //         height = 64,
    //     },
    //     icon = rl.LoadTexture("assets/igel.png")
    // }
    

    // append(&game.ui_elements, p_bar)

    defer{
        
        delete(game.level.player_bullets)
        delete(game.level.enemy_bullets)
        delete(game.level.enemy_fragments)
        delete(game.level.loot)
        delete(game.level.upgrade_pool)
        delete(game.level.available_upgrades)
        delete(game.level.particles)
        delete(game.level.level_visual.tilesets)
        delete(game.level.level_visual.layers)
        delete(game.level.ui_elements)

        delete(game.levels)
        delete(game.menu.elements)
        delete(game.player.statuses)
        delete(game.player.weapon.bullet.applied_status)
        for &e in game.level.enemies{
            delete(e.statuses)
        }
        for &s in game.level.spawner{
            delete(s.enemy.applied_status)
        }
        delete(game.level.enemies)
        delete(game.level.npcs)
        delete(game.level.spawner)
        delete(game.tooltips)
        for &element in game.level.ui_elements{
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

        for k, &v in game.skilltrees{
            delete(v.lines)
            delete(v.nodes)
        }
        delete(game.skilltrees)
        // for k, &v in game.level.skilltrees{
        //     delete(v.lines)
        //     delete(v.nodes)
        // }
        rl.CloseWindow()
    }
    
    if tooltips, ok := get_tooltips(map_allocator); ok{
        game.tooltips = tooltips
    }
    // create_upgrades(&game.level.upgrade_pool)
    create_level(game.current_level)
    
    // if level_visual, ok := m.load_map("assets/test_map.json", map_allocator); ok{
    //     game.player = create_player()
    //     game.player.pos = m.get_player_spawn_pos(level_visual)
    //     game.camera.target = game.player.pos
    //     game.level.level_visual = level_visual
        //Test Spawner
        // spawner := create_spawner(1, 1, 1, 100)
        // spawner.enemy = create_start_enemy({width = 48, height = 32, x = 0, y = 0}, 200, rl.RED)
        // append(&game.level.spawner, spawner)

        // spawner = create_spawner(2, 2, 1, 500)
        // spawner.enemy = create_second_enemy()
        // append(&game.level.spawner, spawner)

        // spawner = create_spawner(1, 1, 1, 500)
        // spawner.enemy = create_third_enemy()
        // append(&game.level.spawner, spawner)

        // spawner = create_spawner(10, 0.1, 0)
        // spawner.enemy = create_dummy_enemy()
        // status := create_poison_status()
        // status.strength = 0.2
        // append(&spawner.enemy.applied_status, status)
        // status = create_fire_status()
        // status.strength = 0.2
        // append(&spawner.enemy.applied_status, status)
        // append(&game.level.spawner, spawner)

        // append(&game.levels, game.level)
        //Test Status
        // status = create_poison_status()
        // append(&game.player.weapon.bullet.applied_status, status)
        // status = create_fire_status()
        // append(&game.player.weapon.bullet.applied_status, status)
        //Test NPC
        // test_npc := create_gunsmith_npc({100, 100})
        // append(&game.level.npcs, test_npc)
        // level_up_spawner_update()
        
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
    v_bar.rec.x += p_bar.rec.width + 60
    v_bar.fill_color = rl.BLUE
    v_bar.type = .Value

    game.player.h_bar = p_bar
    game.player.v_bar = v_bar

    interact := ui.UI_Interact{
        rec = {
            x = f32(rl.GetScreenWidth()/2 - 400),
            y = 50,
            width = 800,
            height = 25,
        },
        text = {
            valign = .Center,
            halign = .Center,
            font_size = 30,
            text_color = rl.WHITE
        },
        interactable = nil,
    }

    game.level.interact = interact

        // ability_test := Radial_Liberation{   
        //     count = 8,
        //     damage = 5,
        // }
        // ability_test := ab.Dash{

        // }
        // ability_cd := Ability_Cooldown{
        //     cast_rate = 5,
        // }
        //TODO -> Make ability cd part of the ability instead of player
        // game.player.ability = ability_test
        // game.player.ability_cd = ability_cd
        // get_upgrade_target(&game.player)
    create_upgrades(&game.level.upgrade_pool)
        // fill_available_upgrades(&game)
        // game.player.h_bar = p_bar
        // game.player.v_bar = v_bar

    pos : rl.Vector2 = {p_bar.rec.x, p_bar.rec.y - 25}
    status_bar := ui.create_ui_status_bar(pos)

        // append(&game.level.ui_elements, cooldown)
        // append(&game.level.ui_elements, game.player.h_bar)
        // append(&game.level.ui_elements, game.player.v_bar)
        // append(&game.level.ui_elements, status_bar)
    init_game()
    for !rl.WindowShouldClose(){
        dt :=  rl.GetFrameTime()
        update_camera(dt)
        check_collisions()
        update_game(dt)
        draw_game()

        if game.should_close{
            break
        }
    }
}
init_game :: proc(){
    init_skilltrees()
}

update_game :: proc(dt : f32) {
    update_helper()
    update_handler(dt)
    if !game.is_paused && !game.level.power_level_up{
        game.play_time += dt
        update_player(dt)
        update_player_interact(dt)
        update_player_shooting(dt)
        update_player_bullets(dt)
        update_npc(dt)
        update_enemy_bullets(dt)
        update_player_casting(dt)
        update_spawner(dt)
        update_enemy(dt)
        update_fragement(dt)
        update_loot(dt)
        update_particle(dt)
        update_in_game_ui(dt)
        update_tooltip(dt)
    } else if game.level.power_level_up{
        update_upgrade(dt)
    } else if game.current_menu == .Skilltree{
        update_menu()
        update_skilltree()
    } else{
        update_menu()
    }
}

check_collisions :: proc(){
    if !game.is_paused && !game.level.power_level_up{
        check_enemy_player()
        check_bullet()
        check_bullet_player()
        check_collisions_detection_loot()
        check_collisions_pickup_loot()
        check_player_interact()
        check_in_game_ui_tooltip()
    } else if game.level.power_level_up{
        check_collision_upgrade_slot()
    } else{
        check_collision_menu()
    }
    if game.current_menu == .Skilltree{
        check_skill_node()
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
    draw_npc()
    draw_loot()
    draw_bullet()
    draw_enemies()
    draw_particles()
    rl.EndMode2D()
    draw_in_game_ui()
    draw_tooltip()
    if game.is_paused{
        draw_menu()
    } else if game.level.power_level_up{
        draw_upgrade()
    }
    if game.current_menu == .Skilltree{
        draw_skilltree()
    }
    rl.EndDrawing()
}

cast_ability :: proc(g : ^Game_State){
    switch &a in g.player.ability{
        case Radial_Liberation:
            cast_radial_liberation(a, &g.level.player_bullets, g.player.pos)
        case Dash:

    }
}

sync_menu :: proc(){
    clear(&game.menu.elements)
    switch game.current_menu{
        case .Pause:
            rec := rl.Rectangle{
                x = f32(rl.GetScreenWidth()) / 2 - 500/2,
                y = f32(rl.GetScreenHeight()) * 0.25,
                width = 500,
                height = 100,
            }
            btn := ui.create_button("Continue", rec, on_click_continue, -1)
            btn.type = .Continue
            append(&game.menu.elements, btn)
            rec.y += btn.rec.height * 2 + 50 
            btn = ui.create_button("Options", rec, on_click_options, -1)
            btn.type = .Options
            append(&game.menu.elements, btn)
            rec.y += btn.rec.height * 2 + 50 
            btn = ui.create_button("Exit", rec, on_click_quit, -1)
            btn.type = .Exit
            append(&game.menu.elements, btn)
        case .Options:
            rec := rl.Rectangle{
                width = 500,
                height = 100,
                x = f32(rl.GetScreenWidth()) / 2 - 500 /2,
                y = f32(rl.GetScreenHeight()) * 0.85
            }
            
            btn := ui.create_button("Back", rec, on_click_back, -1)
            btn.type = .Back
            append(&game.menu.elements, btn)
            rec = rl.Rectangle {x = 100, y = 100, width = 500, height = 100}
            label := ui.create_label("Test dauwildjwaj wdajaidwjaidj  wdjaidjaiod:", rec)
            append(&game.menu.elements, label)

            slider := ui.create_slider({700, 100}, {1000, 100})
            append(&game.menu.elements, slider)
        case.Main:
        case .Gunsmith:
            rec := rl.Rectangle{
                x = f32(rl.GetScreenWidth() / 2 - 50),
                y = f32(100),
                width = 180,
                height = 80,
            }
            btn : ui.UI_Button
            for type in ui.UI_Skill_Tree_Type{
                btn = ui.create_button("Test", rec, on_click_skilltree, type)
                btn.text.font_size = 30
                btn.type = .Skilltree
            }
            append(&game.menu.elements, btn)
            close_btn := btn
            close_btn.text.content = "Close"
            close_btn.rec.y += 100
            close_btn.type = .Continue
            close_btn.on_click = on_click_continue
            append(&game.menu.elements, close_btn)
        case .Skilltree:
            rec := rl.Rectangle{
                x = f32(rl.GetScreenWidth() - 55),
                y = 5,
                width = 50,
                height = 50,
            }
            
            back_btn := ui.create_button("X", rec, on_click_back, -1)
            back_btn.text.font_size = 15
            back_btn.type = .Back
            game.active_skilltree = .NormalBullet
            append(&game.menu.elements, back_btn)
        case .ChooseLevel:
            clear(&game.menu.elements)
            rec := rl.Rectangle{
                x = 100,
                y = 100,
                width = 400,
                height = 100,
            }
            for &type in game.levels{
                // if type == .HQ do continue
                btn := create_choose_level(rec, &type)
                append(&game.menu.elements, btn)
                refresh_ui_pointers()
                rec.y += 105
            }
            btn := ui.create_button("Back", rec, on_click_continue, -1)
            append(&game.menu.elements, btn)
    }
}

fill_available_upgrades :: proc(){
    common : i32
    uncommon : i32
    rare : i32
    epic : i32
    legendary : i32
    for u in game.level.upgrade_pool{
        if u.target == .Player{
            append(&game.level.available_upgrades, u)
        } else if game.player.target_ability == u.target{
            append(&game.level.available_upgrades, u)
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

refresh_ui_pointers :: proc(){
    for &element in game.menu.elements{
        switch &e in element{
            case ui.UI_Cooldown:
            case ui.UI_Button:
                e.data.data = &e.storage
            case ui.UI_Menu:
            case ui.UI_Progress_Bar:
            case ui.UI_Label:
            case ui.UI_Slider:
            case ui.UI_Status_Bar:
        }
    }
}