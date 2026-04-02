package enemy

import "core:slice/heap"
import rl "vendor:raylib"
import cl "../collider"
import h "../health"
import "../ui"

Enemy_Behavior :: #type proc(e : ^Dummy_Enemy, player_pos : rl.Vector2, dt : f32)

Dummy_Enemy :: struct {
    pos : rl.Vector2,
    origin : rl.Vector2,
    speed : f32,
    width : f32,
    height : f32,
    color : rl.Color,
    collidor : cl.Collider_Rectangle,
    update_behavior : Enemy_Behavior,

    health : h.Health,
    health_bar : ui.UI_Progress_Bar,
}

create_enemy :: proc(pos : rl.Vector2) -> Dummy_Enemy{
    enemy := Dummy_Enemy{
        height = 32,
        width = 48,
        pos = pos,
        speed = 200,
        color = rl.BEIGE,
        collidor = {
            height = 32,
            width = 48,
        },
        update_behavior = melee_enemy_behavior,
    }

    health := h.Health{
        current = 20,
        max = 20,
    }

    rect := rl.Rectangle{
        x = pos.x + 20,
        y = pos.y - 20,
        width = enemy.width + 20,
        height = 10,
    }

    enemy.health = health
    enemy.health_bar = ui.create_progress_bar(rect, rl.BLACK, rl.GRAY, rl.RED)
    enemy.health_bar.value = enemy.health.current
    enemy.health_bar.max = enemy.health.max
    enemy.origin = {enemy.pos.x + enemy.width/2, enemy.pos.y + enemy.height/2}

    return enemy
}

update_enemy :: proc(e : ^Dummy_Enemy, player_pos : rl.Vector2, dt : f32){
    e.update_behavior(e, player_pos, dt)
    e.origin = {e.pos.x + e.width/2, e.pos.y + e.height/2}
    e.collidor.pos = e.pos
    e.health_bar.value = e.health.current
}

draw_enemy :: proc(e : Dummy_Enemy){
    rl.DrawRectangleV(e.pos, {e.width, e.height}, e.color)
    ui.draw_progress_bar(e.health_bar)
}

melee_enemy_behavior :: proc(e : ^Dummy_Enemy, player_pos : rl.Vector2, dt : f32){
    dir := player_pos - e.pos
    vel := rl.Vector2Normalize(dir) * e.speed
    e.pos += vel * dt
}