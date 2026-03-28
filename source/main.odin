package game

import "core:strings"
import rl "vendor:raylib"
import "core:fmt"
import "core:mem"

main :: proc(){
    fmt.println("Hello World")

    rl.InitWindow(1920, 1080, "Shapewars: The Circular Resistance")
    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.SetTargetFPS(500)

    track : mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)
    defer{
        for _, entry in track.allocation_map{
            fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
        }
        for entry in track.bad_free_array{
            fmt.eprintf("%v bad free\n", entry.location)
        }
        mem.tracking_allocator_destroy(&track)
    }
     

    game := Game_State {
        player = {
            pos = {640, 320},
            speed = 600,
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
        rl.CloseWindow()
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

    update_player(&game.player, dt)
    bullet, ok_bullet := update_shooting(&game.player, game.camera, dt)

    if ok_bullet{
        append(&game.player_bullets, bullet)
    }

    for &b, idx in game.player_bullets{
        update_bullet(&b, dt)
        check_if_bullet_can_delete(game.camera, b, &game.player_bullets, idx)
    }

    enemy, ok_enemy := update_spawn(game)

    if ok_enemy{
        append(&game.enemies, enemy)
    }

    for &b, idx in game.enemies{
        //Enemy Behavior Code
    }
}

check_collisions :: proc(game : ^Game_State){
    for e, idx_e in game.enemies{
        for b, idx_b in game.player_bullets{
            if check_bullet_enemy(b, e){
                unordered_remove(&game.player_bullets, idx_b)
                unordered_remove(&game.enemies, idx_e)
            }
        }
    }
}

check_if_bullet_can_delete :: proc(c : rl.Camera2D, b : Bullet, bullets : ^[dynamic]Bullet, idx : int){
    view_left := c.target.x - (c.offset.x / c.zoom)
    view_right := c.target.x + (c.offset.x / c.zoom)
    view_top := c.target.y - (c.offset.y / c.zoom)
    view_bottom := c.target.y + (c.offset.y / c.zoom)

    if b.pos.x < view_left || b.pos.x > view_right || b.pos.y < view_top || b.pos.y > view_bottom{
        unordered_remove(bullets, idx)
    }
}

draw_game :: proc(game : ^Game_State){
    draw_player(game.player)
    
    for bullet in game.player_bullets{
        draw_bullet(bullet)
        if game.helper_activated{
            draw_collider(bullet.pos, bullet.collider)
        }
    }

    for enemy in game.enemies{
        draw_enemy(enemy)
        if game.helper_activated{
            draw_collider(enemy.pos, enemy.collidor)
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