package game

import rl "vendor:raylib"
import "ui"

Boss_Ability :: struct{
    cd : Ability_Cooldown,
    cast_time : f32,
    cast_timer : f32,
    cast_ability : proc(e : ^Enemy, dt : f32),
}

Boss_Data :: struct{
    // abilities : [4]Ability,
    ability : Boss_Ability,
    is_casting : bool,
}

call_reinforcement :: proc(b : Enemy){
    e := create_start_enemy()
    for _ in 0..<1{
        e.rec.x = b.origin.x + 150
        e.rec.y = b.origin.y + 150
        rec := rl.Rectangle{
            width = e.rec.width + 20,
            height = 10,
            x = e.rec.x + 10,
            y = e.rec.y + 20,
        }
        e.health_bar = ui.create_progress_bar(rec, rl.BLACK, rl.GRAY, rl.RED)
        e.health_bar.value = e.health.current
        e.health_bar.max = e.health.max
        append(&game.level.enemies, e)
    }
}

test_boss_behavior :: proc(e : ^Enemy, d : ^Behavior_Data, dt : f32){
    data := &d.(Boss_Data)
    if data.ability.cd.cooldown > 0 && !data.is_casting{
        data.ability.cd.cooldown -= dt
    }

    if data.ability.cd.cooldown <= 0 && !data.is_casting{
        data.ability.cast_timer = data.ability.cast_time
        data.is_casting = true
    }

    if data.is_casting && data.ability.cast_timer > 0{
        data.ability.cast_timer -= dt
    }

    if data.is_casting && data.ability.cast_timer <= 0{
        data.ability.cd.cooldown = data.ability.cd.cast_rate
        call_reinforcement(e^)
        data.is_casting = false
    }

    if data.is_casting do return
    dir := game.player.pos - {e.rec.x, e.rec.y}
    vel := rl.Vector2Normalize(dir) * e.speed
    new_pos : rl.Vector2 = {e.rec.x, e.rec.y}
    new_pos += vel * dt
    e.rec.x = new_pos.x
    e.rec.y = new_pos.y
}