package bullet

import "core:fmt"
import rl "vendor:raylib"
import cl "../collider"

Bullet :: struct {
    damage : f32,
    pos : rl.Vector2,
    dir : rl.Vector2,
    vel : rl.Vector2,
    speed : f32,
    radius : f32,
    collider : cl.Collider_Circle,
    is_active : bool
}

update_bullet :: proc(b : ^Bullet, dt : f32){
    b.vel = b.dir * b.speed //Not 100% sure, but can probaly be called once
    b.pos += b.vel * dt
    b.collider.pos = b.pos
}

draw_bullet :: proc(b : Bullet){
    rl.DrawCircleV(b.pos, b.radius, rl.RED)
}

create_bullet :: proc(pos : rl.Vector2, c : rl.Camera2D) -> Bullet{
    mouse_pos := rl.GetMousePosition()
    world_pos := rl.GetScreenToWorld2D(mouse_pos, c)
    b := Bullet{
        damage = 10,
        radius = 8,
        speed = 500,
        pos = pos,
        dir = rl.Vector2Normalize(world_pos - pos),
        is_active = true,
    }
    b.collider = {
        pos = pos,
        radius = b.radius,
    }
    return b
}