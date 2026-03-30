package collider

import rl "vendor:raylib"

Collider :: union{
    Collider_Circle,
    Collider_Rectangle,
}

Collider_Rectangle :: struct {
    width : f32,
    height : f32,
}

Collider_Circle :: struct{
    radius : f32,
}

draw_collider_cirlce :: proc(pos : rl.Vector2, c : Collider_Circle){
    rl.DrawCircleV(pos, c.radius, rl.GREEN)
}

draw_collider_rect :: proc(pos : rl.Vector2, c : Collider_Rectangle){
    rl.DrawRectangleV(pos, {c.width, c.height}, rl.GREEN)
}