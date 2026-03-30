package enemy

import rl "vendor:raylib"
import cl "../collider"
import h "../health"

Enemy_Behavior :: #type proc(e : ^Dummy_Enemy, dt : f32)

Dummy_Enemy :: struct {
    pos : rl.Vector2,
    width : f32,
    height : f32,
    color : rl.Color,
    collidor : cl.Collider_Rectangle,
    update_behavior : Enemy_Behavior,

    health : h.Health,
    health_bar : h.Health_Bar,
}

update_enemy :: proc(){

}

draw_enemy :: proc(e : Dummy_Enemy){
    rl.DrawRectangleV(e.pos, {e.width, e.height}, e.color)
    h.draw_health_bar(e.health_bar, e.health)
}