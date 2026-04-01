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
    }

    cooldown := ui.UI_Cooldown{
        pos = {50, f32(rl.GetScreenHeight() - 100)},
        width = 64,
        height = 64,
        icon = rl.LoadTexture("assets/igel.png")
    }
    append(&game.ui_elements, cooldown)
    
    defer{
        delete(game.player_bullets)
        delete(game.particles)
        delete(game.enemies)
        delete(game.level.tilesets)
        delete(game.level.layers)
        delete(game.ui_elements)
        delete(game.menu.elements)
        // delete(game.last_menu.elements)
        // delete(game.menu.elements)
        rl.CloseWindow()
    }

    // level, ok := m.load_map("assets/test_map.json", map_allocator)
    ok := true
    if ok{
        // game.level = level
        game.player = pl.create_player(game.level)
        game.camera.target = game.player.pos

        ability_test := ab.Radial_Liberation{   
            count = 8,
            cooldown = {
                cooldown = 5,
            }
        }
        game.player.ability = ability_test
    } else{
        panic("Could not load the level!")
    }
    for !rl.WindowShouldClose(){
        dt :=  rl.GetFrameTime()
        activate_helper(&game)
        update_game(&game, dt)
        check_collisions(&game)
        game.camera.target += handler.get_camera_follow_pos(game.player.pos, game.camera, dt)

        rl.BeginDrawing()
        rl.BeginMode2D(game.camera)
        draw_game(&game)
        rl.EndMode2D()
        draw_ui(game)
        rl.EndDrawing()
        if game.should_close{
            break
        }
    }
}

update_game :: proc(game : ^Game_State, dt : f32) {
    if handler.update_pausing(){
        game.is_paused = !game.is_paused
        game.menu = ui.create_menu(.Pause)
        if !game.is_paused{
            clear(&game.menu.elements)
            clear(&game.last_menu.elements)
        }
    }

    if game.is_paused{
        ui.update_menu(&game.menu)
        check_interaction_with_menu_ui(game)
        return  
    }

    game.play_time += dt

    pl.update_player(&game.player, dt, game.level)
    bullet, ok_bullet := pl.update_shooting(&game.player, game.camera, dt)
    casting := ab.update_casting(&game.player.ability)

    if ok_bullet{
        append(&game.player_bullets, bullet)
    }

    if casting{
        cast_ability(game)
    }

    ab.update_ability(&game.player.ability, dt)

    for &b, idx in game.player_bullets{
        bu.update_bullet(&b, dt)
        if check_if_bullet_can_delete(game.camera, b){
            unordered_remove(&game.player_bullets, idx)
        }
    }

    enemy_inst, ok_enemy := update_spawn(game)

    if ok_enemy{
        append(&game.enemies, enemy_inst)
    }

    for &e, idx in game.enemies{
        enemy.update_enemy(&e, game.player.pos, dt)
        h.update_health_bar(e.pos, &e.health_bar, e.health)
    }

    for &p, idx in game.particles{
        pacl.update_particle(&p, dt)
    }

    
}

check_collisions :: proc(game : ^Game_State){

    for b, idx_b in game.player_bullets{
        for &e, idx_e in game.enemies{
            e_rec := rl.Rectangle{x = e.pos.x, y = e.pos.y, width = e.width, height = e.height}
            if cl.check_bullet_enemy(b.pos, b.radius, e_rec){
                particle_pos : rl.Vector2 = {e.pos.x + (e.width/2), e.pos.y + (e.height/2)}
                pacl.create_hit_particles(&game.particles, particle_pos)
                h.take_damage(b, &e.health)
                if e.health.is_dead{
                    unordered_remove(&game.enemies, idx_e)
                }
                if len(game.player_bullets) - 1 >= idx_b{
                    unordered_remove(&game.player_bullets, idx_b)
                }
            }
        }
        if cl.check_bullet_wall(b.pos, b.radius, game.level){
            particle_pos : rl.Vector2 = {b.pos.x + b.radius, b.pos.y + b.radius}
            pacl.create_destroy_bullet_particle(&game.particles, particle_pos)
            unordered_remove(&game.player_bullets, idx_b)
        }
    }
}

check_if_bullet_can_delete :: proc(c : rl.Camera2D, b : bu.Bullet) -> bool{
    c_world := handler.get_camera_world_position(c)

    return b.pos.x < c_world.left || b.pos.x > c_world.right || b.pos.y < c_world.top || b.pos.y > c_world.bottom 
}

draw_game :: proc(game : ^Game_State){
    rl.ClearBackground(rl.BLUE)
    // m.draw_map(game.level, game.helper_activated)
    pl.draw_player(game.player)
    
    for bullet in game.player_bullets{
        bu.draw_bullet(bullet)
        if game.helper_activated{
            cl.draw_collider_cirlce(bullet.pos, bullet.collider)
        }
    }

    for e in game.enemies{
        enemy.draw_enemy(e)
        if game.helper_activated{
            cl.draw_collider_rect(e.pos, e.collidor)
        }
    }

    for p, idx in game.particles{
        pacl.draw_particles(p)
        if(!p.alive){
            unordered_remove(&game.particles, idx)
        }
    }

}

draw_ui :: proc(game : Game_State){
    for element in game.ui_elements{
        switch specified_element in element{
            //TODO FIX
            case ui.UI_Cooldown: ui.draw_cooldown(specified_element, ab.get_cooldown(game.player.ability))
            case ui.UI_Button:
            case ui.UI_Menu:
        }
    }

    if game.is_paused{
        ui.draw_menu(game.menu)
    }
    
}

cast_ability :: proc(g : ^Game_State){
    switch &a in g.player.ability{
        case ab.Radial_Liberation:
            ab.cast_radial_liberation(a, &g.player_bullets, g.player.pos)
    }
}

draw_help_stuff :: proc(game : Game_State){
    ability := ab.get_cooldown(game.player.ability)
    rl.DrawFPS(20, 50)
    str := fmt.tprintf("%.2f, %.2f | %.2f | %.2f", game.player.pos.x, game.player.pos.y, game.player.vel, ability.timer)
    cstr := strings.clone_to_cstring(str)
    delete_cstring(cstr)
    rl.DrawText(cstr, 150, 50, 20, rl.LIGHTGRAY)
    str = fmt.tprintf("%.0f", game.play_time)
    cstr = strings.clone_to_cstring(str)
    rl.DrawText(cstr, 150, 100, 20, rl.LIGHTGRAY)
    delete_cstring(cstr)
}

check_interaction_with_menu_ui :: proc(g : ^Game_State){
    for &element in g.menu.elements{
        switch &e in element{
            case ui.UI_Button:
                if e.state == .Pressed{
                    check_which_btn_was_pressed(g, &e)
                }
            case ui.UI_Menu:
            case ui.UI_Cooldown:
        }
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