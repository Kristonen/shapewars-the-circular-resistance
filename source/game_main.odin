package game

import "core:reflect"
import "core:mem/virtual"
import "core:strings"
import rl "vendor:raylib"
import "core:fmt"
import "core:mem"
import m "map"
import "ui"

//////////////////////////////////////////////////////
//   Project to learn the odin programming language //
//////////////////////////////////////////////////////

main :: proc(){
    
    rl.InitWindow(1920, 1080, "Shapewars: The Circular Resistance")
    rl.InitAudioDevice()
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
    game.map_arena = arena

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
        current_menu = .Play,
        create_hit_particle = create_hit_particles,
        current_level = .HQ,
        skill_points = 100,
    }
    for idx in 0..<len(Level_Type){
        type := Level_Type(idx)
        append(&game.levels, type)
    }

    sync_menu()

    defer{
        save_game()
        for &b in game.level.player_bullets{
            delete(b.hitted_enemies)
        }
        delete(game.level.player_bullets)
        delete(game.level.enemy_bullets)
        delete(game.level.ability_projectiles)
        delete(game.level.enemy_fragments)
        delete(game.level.area_effects)
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
        delete(Enemies.viper_enemy.applied_status)
        delete(game.level.enemies)
        delete(game.level.npcs)
        delete(game.level.spawner)
        delete(game.tooltips)
        for &element in game.level.ui_elements{
            switch &e in &element{
                case ui.UI_Panel:
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
        rl.CloseWindow()
    }
    init_game()
    load_game()
    create_level(game.current_level)
    game.level.interact = {
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
    create_upgrades(&game.level.upgrade_pool)
    // fill_available_upgrades()
    game.level.portal = create_portal({0, 0})
    game.level.portal.texture = rl.LoadTexture("assets/portal.png")
    
    game.fbo = rl.LoadRenderTexture(rl.GetScreenWidth(), rl.GetScreenHeight())
    s := create_poison_status(1, 0.2, 10)
    //Game Loop
    for !rl.WindowShouldClose(){
        dt :=  rl.GetFrameTime()

        check_collisions()
        update_game(dt)
        draw_game()

        if game.should_close{
            break
        }
    }
}
init_game :: proc(){
    init_player()
    init_skilltrees()
    init_shaders()
    init_unlockables()
    init_enemies()
}

load_game :: proc(){
    load_game_data()
    load_skilltree()
    load_tooltips()
}

save_game :: proc(){
    save_game_data()
    save_skilltree()
}

update_game :: proc(dt : f32) {
    update_camera(dt)
    update_handler(dt)
    if !game.is_paused && !game.level.power_level_up{
        game.play_time += dt
        update_player(dt)
        update_player_interact(dt)
        update_player_casting(dt)
        update_player_shooting(dt)
        update_player_bullets(dt)
        update_player_indicator(dt)
        update_npc(dt)
        update_enemy_bullets(dt)
        update_spawner(dt)
        update_enemy(dt)
        update_area_effect(dt)
        update_fragement(dt)
        update_loot(dt)
        update_particle(dt)
        update_in_game_ui(dt)
        update_tooltip(dt)
        update_portal(dt)
        update_ability_projectiles(dt)
    } 
    if game.is_paused && game.current_menu != .Skilltree{
        update_menu()  
    } else if game.level.power_level_up{
        update_upgrade(dt)
    } else if game.current_menu == .Skilltree{
        update_menu()
        update_skilltree()
    }
}

check_collisions :: proc(){
    if !game.is_paused && !game.level.power_level_up{
        check_enemy()
        check_enemy_player()
        check_bullet()
        check_bullet_player()
        check_collisions_detection_loot()
        check_collisions_pickup_loot()
        check_player_area_effect()
        check_player_interact()
        check_in_game_ui_tooltip()
    }
    if game.is_paused{
        check_collision_menu()
    } else if game.level.power_level_up{
        check_collision_upgrade_slot()
    }
    if game.current_menu == .Skilltree{
        check_skill_node()
    }
}

draw_game :: proc(){

    rl.BeginTextureMode(game.fbo)
            rl.ClearBackground(rl.BLANK)
            for s in game.level.upgrade_menu.upgrades{
                rl.DrawRectangleRoundedLinesEx(s.rect, 0.01, 1, 2, s.color)
            }
    rl.EndTextureMode()
    
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLUE)
    rl.BeginMode2D(game.camera)
        if game.map_drawing{
            draw_map()
        }
        draw_ability_projectiles()
        draw_area_effects()
        draw_fragments()
        draw_player_indicator()
        draw_player()
        draw_npc()
        draw_loot() 
        draw_chest()
        draw_bullet()
        draw_enemies()
        draw_particles()
        draw_portal()
        // if game.player.ability.active{
        //     game.player.ability.draw()
        // }
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
    rl.DrawFPS(25, 25)
    rl.EndDrawing()
}

sync_menu :: proc(){
    clear(&game.menu.elements)
    switch game.current_menu{
        case .Play:
        case .Main:
        case .Stats:
            ui.create_menu(&game.menu)
            rec := rl.Rectangle{
                x = f32(rl.GetScreenWidth()/2 - 500),
                y = f32(rl.GetScreenHeight())*0.05,
                width = 1000,
                height = 800,
            }
            p := ui.create_panel(rec, rl.GRAY, 100)
            append(&game.menu.elements, p)
            rec.x += p.rec.width/2 - 125
            rec.y += 5
            rec.width = 250
            rec.height = 100
            l := ui.create_label(get_player_health_as_string(), rec)
            l.text.font_size = 20
            append(&game.menu.elements, l)
            rec.y += 105
            l = ui.create_label(get_player_damage_as_string(), rec)
            l.text.font_size = 20
            append(&game.menu.elements, l)
            rec.y += 105
            l = ui.create_label(get_player_attack_speed_as_string(), rec)
            l.text.font_size = 20
            append(&game.menu.elements, l)
        case .Pause:
            ui.create_menu(&game.menu)
            rec := rl.Rectangle{
                x = f32(rl.GetScreenWidth()) / 2 - 250,
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
        case .Gunsmith:
            rec := rl.Rectangle{
                x = f32(rl.GetScreenWidth() / 2 - 50),
                y = f32(100),
                width = 250,
                height = 100,
            }
            btn : ui.UI_Button
            for &u in game.unlockables{
                if u.type == .Ability do continue
                text := fmt.tprintf("%v", u.data)
                btn = ui.create_button(text, rec, on_click_skilltree, u.data)
                btn.text.font_size = 30
                btn.type = .Skilltree
                if !u.unlocked{
                    btn.disabled = true
                    btn.text.content = "???"
                }
                append(&game.menu.elements, btn)
                refresh_ui_pointers()
                rec.y += 105
            }
            btn.disabled = false
            close_btn := ui.create_button("Close", rec, on_click_continue, -1)
            close_btn.text.font_size = 30
            append(&game.menu.elements, close_btn)
        case .Catalyst:
            rec := rl.Rectangle{
                x = f32(rl.GetScreenWidth() / 2 - 50),
                y = f32(100),
                width = 300,
                height = 100,
            }
            for &u in game.unlockables{
                if u.type == .Weapon do continue
                text := fmt.tprintf("%v", u.data)
                btn := ui.create_button(text, rec, on_click_skilltree, u.data)
                btn.type = .Skilltree
                btn.text.font_size = 30
                if !u.unlocked{
                    btn.disabled = true
                    btn.text.content = "???"
                }
                append(&game.menu.elements, btn)
                refresh_ui_pointers()
                rec.y += 105
            }
            close_btn := ui.create_button("Close", rec, on_click_continue, -1)
            close_btn.type = .Continue
            close_btn.text.font_size = 30
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
                if type == .HQ do continue
                btn := create_choose_level(rec, &type)
                append(&game.menu.elements, btn)
                refresh_ui_pointers()
                rec.y += 105
            }
            btn := ui.create_button("Back", rec, on_click_continue, -1)
            append(&game.menu.elements, btn)
        case .Quartermaster:
            rec := rl.Rectangle{
                x = f32(rl.GetScreenWidth()/2) - 450,
                y = f32(rl.GetScreenHeight()/2) - 250,
                width = 400,
                height = 200,
            }
            type : Unlocked_Type = .Weapon
            weapon_btn := ui.create_button("Weapons", rec, on_click_equiptment_menu, type)
            append(&game.menu.elements, weapon_btn)
            rec.x = f32(rl.GetScreenWidth()/2 + 50)
            type = .Ability
            ability_btn := ui.create_button("Abilities", rec, on_click_equiptment_menu, type)
            append(&game.menu.elements, ability_btn)
            rec.x = f32(rl.GetScreenWidth()/2 - 200)
            rec.y = f32(rl.GetScreenHeight() - 300)
            back_btn := ui.create_button("Close", rec, on_click_continue, -1)
            append(&game.menu.elements, back_btn)
            refresh_ui_pointers()
        case .Craftman:
            rec := rl.Rectangle{
                x = 5,
                y = 5,
                width = 250,
                height = 150,
            }
            for i in 0..<len(game.unlockables){
                text := game.unlockables[i].name
                not_buyable := !game.unlockables[i].unlocked && game.unlockables[i].blueprints == 0
                
                btn := ui.create_button(text, rec, on_click_select_craftable, game.unlockables[i].data)

                if not_buyable{
                    btn.text.content = "???"
                    btn.disabled = true   
                }

                btn.text.font_size = 25
                append(&game.menu.elements, btn)
                rec.y += 160
                if i == 5{
                    rec.x += 270
                    rec.y = 5
                }
            }
            rec.x = f32(rl.GetScreenWidth()-55)
            rec.y = 5
            rec.width = 50
            rec.height = 50
            close_btn := ui.create_button("X", rec, on_click_continue, -1)
            close_btn.text.font_size = 15
            append(&game.menu.elements, close_btn)
            rec.x = f32(rl.GetScreenWidth())*0.3 + 5
            rec.y = 505
            rec.width = 250
            rec.height = 100
            buy_btn := ui.create_button("Buy", rec, on_click_craft, -1)
            buy_btn.text.font_size = 20
            buy_btn.show = false
            buy_btn.disabled = true
            append(&game.menu.elements, buy_btn)
            refresh_ui_pointers()
        case .EquiptmentBullet:
            create_equiptment_menu(.Weapon)
        case .EquiptmentAbility:
            create_equiptment_menu(.Ability)
    }
}

create_equiptment_menu :: proc(type : Unlocked_Type){
            start_x := f32(rl.GetScreenWidth())*0.25-400
            counter := 0
            rec := rl.Rectangle{
                x = start_x,
                y = f32(rl.GetScreenHeight())/2 - 300,
                width = 400,
                height = 200,
            }
            for i in 0..<len(game.unlockables){
                if game.unlockables[i].type != type do continue
                if counter == 3{
                    rec.x = start_x
                    rec.y += 250
                }
                text := game.unlockables[i].unlocked ? game.unlockables[i].name : "???"
                btn := ui.create_button(text, rec, on_equip, game.unlockables[i].data)
                btn.disabled = !game.unlockables[i].unlocked
                rec.x += 450
                append(&game.menu.elements, btn)
                counter += 1
            }
            rec.x -= (2*450)
            rec.y += 250
            back_btn := ui.create_button("Back", rec, on_click_back, -1)
            append(&game.menu.elements, back_btn)
            refresh_ui_pointers()
}

fill_available_upgrades :: proc(){
    common : i32
    uncommon : i32
    rare : i32
    epic : i32
    legendary : i32
    clear(&game.level.available_upgrades)
    for u in game.level.upgrade_pool{
        if u.target == .NormalBullet{
            append(&game.level.available_upgrades, u)
        } else if game.player.current_ability == u.target{
            append(&game.level.available_upgrades, u)
        } else if game.player.current_weapon == u.target{
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
            case ui.UI_Panel:
        }
    }
}