package game

import "core:fmt"
import "core:math"
import "ui"

import rl "vendor:raylib"

Reinforcment_Data :: struct{
    pos : rl.Vector2,
}

activate_reinforcement :: proc(a : ^Ability, dt : f32){
    e := Enemies.dummy_enemy
    data := a.data.(Reinforcment_Data)
    directions := []rl.Vector2 {{data.pos.x - 150, data.pos.y - 150}, {data.pos.x + 150, data.pos.y - 150}, {data.pos.x + 150, data.pos.y + 150}, {data.pos.x - 150, data.pos.y + 150}}
    for dir in directions{
        e.rec.x = dir.x
        e.rec.y = dir.y
        rec := rl.Rectangle{
            width = e.rec.width + 20,
            height = 10,
            x = e.rec.x + 10,
            y = e.rec.y + 20,
        }
        e.health_bar = ui.create_progress_bar(rec, rl.BLACK, rl.GRAY, rl.RED)
        e.health_bar.value = e.health.current
        e.health_bar.max = e.health.max
        if ok := add_entity_to_game(&e); !ok do return
    }
}

draw_reinforcment :: proc(pos : rl.Vector2){
    for i in 0..<20{
        angle := (f32(i) / 20.0) * (2.0 * math.PI)
        dir := rl.Vector2{
            math.cos(angle), math.sin(angle)
        }
        speed : f32 = 200
        p := Particle{
            pos = pos,
            vel = {dir.x * speed, dir.y * speed},
            color = rl.BLACK,
            size = 10,
            max_life = 0.5,
            alive = true,
            type = .Normal,
        }
        append(&game.level.particles, p)
    }
}