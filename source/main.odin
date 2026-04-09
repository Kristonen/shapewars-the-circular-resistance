package game

import "core:mem/virtual"
import "core:strings"
import rl "vendor:raylib"
import "core:fmt"
import "core:mem"
import bu "bullet"
import cl "collider"
import pl "player"
import enemy "enemy"
import m "map"
import h "health"
import pacl "particle"
import ab "ability"
import "ui"
import "handler"
import "loot"
import "upgrade"

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

    game := Game_State {
        camera = {
            zoom = 1,
            offset = {f32(rl.GetScreenWidth())/2, f32(rl.GetScreenHeight())/2},
        },
        helper_activated = false,
        current_menu = .Pause,
    }
    sync_menu(&game)

    cooldown := ui.UI_Cooldown{
        pos = {550, f32(rl.GetScreenHeight() - 100)},
        width = 64,
        height = 64,
        icon = rl.LoadTexture("assets/igel.png")
    }
    append(&game.ui_elements, cooldown)

    // append(&game.ui_elements, p_bar)

    defer{
        delete(game.player_bullets)
        delete(game.particles)
        delete(game.enemies)
        delete(game.level.tilesets)
        delete(game.level.layers)
        delete(game.ui_elements)
        delete(game.menu.elements)
        delete(game.loot)
        delete(game.upgrade_pool)
        rl.CloseWindow()
    }
    level, ok := m.load_map("assets/test_map.json", map_allocator)
    if ok{
        game.level = level
        game.player = pl.create_player(game.level)
        game.player.pos = m.get_player_spawn_pos(game.level)
        game.camera.target = game.player.pos
        upgrade.create_upgrades(&game.upgrade_pool)
        
        rect := rl.Rectangle {
            x = 50,
            y = f32(rl.GetScreenHeight() - 100),
            width = f32(rl.GetScreenWidth()) * 0.25,
            height = 50,
        }
        p_bar := ui.create_progress_bar(rect, rl.BLACK, rl.GRAY, rl.RED)
        p_bar.show_text = true
        p_bar.min = 0
        p_bar.max = game.player.health.max
        p_bar.value = game.player.health.current
        p_bar.type = .Health

        v_bar := p_bar
        v_bar.rect.x += p_bar.rect.width + 100
        v_bar.type = .Value
        v_bar.fill_color = rl.BLUE
        v_bar.value = game.player.loot_bag.value
        v_bar.max = game.player.loot_bag.max_value


        ability_test := ab.Radial_Liberation{   
            count = 8,
            damage = 5,
        }
        ability_cd := ab.Ability_Cooldown{
            cast_rate = 5,
        }
        game.player.ability = ability_test
        game.player.ability_cd = ability_cd
        game.player.h_bar = p_bar
        game.player.v_bar = v_bar
        append(&game.ui_elements, game.player.h_bar)
        append(&game.ui_elements, game.player.v_bar)
    } else{
        panic("Could not load the level!")
    }
    for !rl.WindowShouldClose(){
        dt :=  rl.GetFrameTime()
        
        update_game(&game, dt)
        check_collisions(&game)
        game.camera.target += handler.get_camera_follow_pos(game.player.pos, game.camera, dt)
        draw_game(game)

        if game.should_close{
            break
        }
    }
}

update_game :: proc(g : ^Game_State, dt : f32) {
    update_helper(g)
    update_handler(g, dt)
    if !g.is_paused && !g.level_up{
        g.play_time += dt
        update_player(g, dt)
        update_player_shooting(g, dt)
        update_player_bullets(g, dt)
        update_player_casting(g, dt)
        update_manual_spawn(g)
        update_enemies(g, dt)
        update_loot(g, dt)
        update_particle(g, dt)
        update_in_game_ui(g, dt)
    } else if g.level_up{
        update_upgrade(g, dt)
    } else{
        update_menu(g)
    }
}

check_collisions :: proc(g : ^Game_State){
    if !g.is_paused && !g.level_up{
        check_bullet(g)
        check_collisions_detection_loot(g)
        check_collisions_pickup_loot(g)
    } else if g.level_up{
        check_collision_upgrade_slot(g)
    } else{
        check_collision_menu(g)
    }
}

//     for &l, idx in game.loot{
//         if !l.is_active do continue
//         if cl.check_circle_circle(game.player.collider, l.pickup){
//             pl.increase_value(&game.player.loot_bag, l.value)
//             ui.update_progress_bar_player(&game.player.v_bar, game.player.loot_bag.value, game.player.loot_bag.max_value)
//             unordered_remove(&game.loot, idx)
//         }

//         if cl.check_circle_circle(game.player.collider, l.detection){
//             l.is_following = true
//         }
//     }
// }

draw_game :: proc(g : Game_State){
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLUE)
    rl.BeginMode2D(g.camera)
    if g.map_drawing{
        draw_map(g)
    }
    draw_player(g)
    draw_bullet(g)
    draw_enemies(g)
    draw_loot(g)
    draw_particles(g)
    rl.EndMode2D()
    draw_in_game_ui(g)
    if g.is_paused{
        draw_menu(g)
    } else if g.level_up{
        draw_upgrade(g)
    }
    rl.EndDrawing()
}

cast_ability :: proc(g : ^Game_State){
    switch &a in g.player.ability{
        case ab.Radial_Liberation:
            ab.cast_radial_liberation(a, &g.player_bullets, g.player.pos)
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