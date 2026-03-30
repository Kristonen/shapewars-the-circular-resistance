package bullet

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
}

update_bullet :: proc(b : ^Bullet, dt : f32){
    b.vel = b.dir * b.speed //Not 100% sure, but can probaly be called one
    b.pos += b.vel * dt
}

draw_bullet :: proc(b : Bullet){
    rl.DrawCircleV(b.pos, b.radius, rl.RED)
}