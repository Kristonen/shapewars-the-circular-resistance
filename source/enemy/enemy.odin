package enemy

import "vendor:stb/rect_pack"
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
    visual_scale : rl.Vector2,
    color : rl.Color,
    collidor : cl.Collider_Rectangle,
    update_behavior : Enemy_Behavior,

    health : h.Health,
    health_bar : ui.UI_Progress_Bar,
    knocback : Knockback,
}

Knockback :: struct{
    strength : f32,
    vel : rl.Vector2,
    threshold : f32,
    friction : f32,
    apply : proc(k : ^Knockback, a_pos : rl.Vector2, v_pos : ^rl.Vector2),
}

apply_knockback :: proc(k : ^Knockback, a_pos : rl.Vector2, v_pos : ^rl.Vector2){
    dir := v_pos^ - a_pos
    dir = rl.Vector2Normalize(dir)
    k.vel += dir * k.strength
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
        knocback = {
            strength = 400,
            friction = 0.9,
            threshold = 10,
            apply = apply_knockback,
        },
        visual_scale = {1, 1},
    }

    health := h.Health{
        current = 20,
        max = 20,
        take_dmg = h.take_damage,
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

melee_enemy_behavior :: proc(e : ^Dummy_Enemy, player_pos : rl.Vector2, dt : f32){
    dir := player_pos - e.pos
    vel := rl.Vector2Normalize(dir) * e.speed
    e.pos += vel * dt
}