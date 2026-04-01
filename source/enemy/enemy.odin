package enemy

import rl "vendor:raylib"
import cl "../collider"
import h "../health"
import "../ui"

Enemy_Behavior :: #type proc(e : ^Dummy_Enemy, player_pos : rl.Vector2, dt : f32)

Dummy_Enemy :: struct {
    pos : rl.Vector2,
    speed : f32,
    width : f32,
    height : f32,
    color : rl.Color,
    collidor : cl.Collider_Rectangle,
    update_behavior : Enemy_Behavior,

    health : h.Health,
    health_bar : ui.UI_Progress_Bar,
}

update_enemy :: proc(e : ^Dummy_Enemy, player_pos : rl.Vector2, dt : f32){
    // melee_enemy_behavior(e, player_pos, dt)
    e.update_behavior(e, player_pos, dt)
}

draw_enemy :: proc(e : Dummy_Enemy){
    rl.DrawRectangleV(e.pos, {e.width, e.height}, e.color)
    ui.draw_progress_bar(e.health_bar, e.health.current, e.health.max)
}

melee_enemy_behavior :: proc(e : ^Dummy_Enemy, player_pos : rl.Vector2, dt : f32){
    dir := player_pos - e.pos
    vel := rl.Vector2Normalize(dir) * e.speed
    e.pos += vel * dt
}