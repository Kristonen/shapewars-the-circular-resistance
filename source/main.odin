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
        player = {
            // pos = {640, 320},
            speed = 400,
            radius = 32,
            weapon = {
                fire_rate = 0.5,
            }
        },
        camera = {
            zoom = 1,
            offset = {f32(rl.GetScreenWidth())/2, f32(rl.GetScreenHeight())/2},
        },
        helper_activated = false,
    }
    game.camera.target = game.player.pos

    defer{
        delete(game.player_bullets)
        delete(game.particles)
        delete(game.enemies)
        delete(game.level.tilesets)
        delete(game.level.layers)
        rl.CloseWindow()
    }

    level, ok := m.load_map("assets/test_map.json", map_allocator)
    if ok{
        game.level = level
        pl.give_player_spawn_pos(game.level, &game.player)
        fmt.println(game.player.pos)
    } else{
        panic("Could not load the level!")
    }

    for !rl.WindowShouldClose(){
        dt :=  rl.GetFrameTime()
        activate_helper(&game)
        update_game(&game, dt)
        check_collisions(&game)

        lerp_speed : f32 = 5.0
        game.camera.target.x += (game.player.pos.x - game.camera.target.x) * lerp_speed * dt
        game.camera.target.y += (game.player.pos.y - game.camera.target.y) * lerp_speed * dt

        rl.BeginDrawing()
        rl.BeginMode2D(game.camera)
        rl.ClearBackground(rl.BLUE)
        draw_game(&game)
        rl.EndMode2D()
        draw_ui(game)
        rl.EndDrawing()
    }
}

update_game :: proc(game : ^Game_State, dt : f32) {
    if !game.is_paused {
        game.play_time += dt
    }

    pl.update_player(&game.player, dt, game.level)
    bullet, ok_bullet := pl.update_shooting(&game.player, game.camera, dt)

    if ok_bullet{
        append(&game.player_bullets, bullet)
    }

    for &b, idx in game.player_bullets{
        bu.update_bullet(&b, dt)
        check_if_bullet_can_delete(game.camera, b, &game.player_bullets, idx)
    }

    enemy_inst, ok_enemy := update_spawn(game)

    if ok_enemy{
        append(&game.enemies, enemy_inst)
    }

    for &b, idx in game.enemies{
        //Enemy Behavior Code
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
                unordered_remove(&game.player_bullets, idx_b)
            }
        }
        if cl.check_bullet_wall(b.pos, b.radius, game.level){
            particle_pos : rl.Vector2 = {b.pos.x + b.radius, b.pos.y + b.radius}
            pacl.create_destroy_bullet_particle(&game.particles, particle_pos)
            unordered_remove(&game.player_bullets, idx_b)
        }
    }
}

check_if_bullet_can_delete :: proc(c : rl.Camera2D, b : bu.Bullet, bullets : ^[dynamic]bu.Bullet, idx : int){
    view_left := c.target.x - (c.offset.x / c.zoom)
    view_right := c.target.x + (c.offset.x / c.zoom)
    view_top := c.target.y - (c.offset.y / c.zoom)
    view_bottom := c.target.y + (c.offset.y / c.zoom)

    if b.pos.x < view_left || b.pos.x > view_right || b.pos.y < view_top || b.pos.y > view_bottom{
        unordered_remove(bullets, idx)
    }
}

draw_game :: proc(game : ^Game_State){
    m.draw_map(game.level, game.helper_activated)
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
    rl.DrawFPS(20, 50)
    str := fmt.tprintf("%.2f, %.2f | %.2f", game.player.pos.x, game.player.pos.y, game.player.vel)
    cstr := strings.clone_to_cstring(str)
    delete_cstring(cstr)
    rl.DrawText(cstr, 150, 50, 20, rl.LIGHTGRAY)
    str = fmt.tprintf("%.0f", game.play_time)
    cstr = strings.clone_to_cstring(str)
    rl.DrawText(cstr, 150, 100, 20, rl.LIGHTGRAY)
    delete_cstring(cstr)
}