package collider

import "core:fmt"
import rl "vendor:raylib"

Collider :: union{
    Collider_Circle,
    Collider_Rectangle,
}

Collider_Rectangle :: struct {
    pos : rl.Vector2,
    width : f32,
    height : f32,
}

Collider_Circle :: struct{
    pos : rl.Vector2,
    radius : f32,
}

draw_collider_cirlce :: proc(c : Collider_Circle){
    color := rl.GREEN
    color.a = 100
    rl.DrawCircleV(c.pos, c.radius, color)
}

draw_collider_rect :: proc(c : Collider_Rectangle){
    color := rl.GREEN
    color.a = 100
    rl.DrawRectangleV(c.pos, {c.width, c.height}, color)
}