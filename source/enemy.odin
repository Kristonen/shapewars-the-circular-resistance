package game

import rl "vendor:raylib"

Enemy_Behavior :: #type proc(e : ^Dummy_Enemy, dt : f32)

Dummy_Enemy :: struct {
    max_health : f32,
    current_health : f32,
    pos : rl.Vector2,
    width : f32,
    height : f32,
    color : rl.Color,
    collidor : Collider,
    update_behavior : Enemy_Behavior,
}

update_enemy :: proc(){

}

draw_enemy :: proc(e : Dummy_Enemy){
    rl.DrawRectangleV(e.pos, {e.width, e.height}, e.color)
}