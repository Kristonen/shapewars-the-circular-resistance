package game

import "core:math"
import "core:container/intrusive/list"
import rl "vendor:raylib"
import "ui"

Boss_Data :: struct{
    abilities : [4]Ability,
    is_casting : bool,
    current_cast : i32,
}

Enemy_Ability_Slot :: struct{
    ability : Ability,
    active : bool,
}

create_test_boss :: proc() -> Enemy{
    rec := rl.Rectangle{x = 0, y = 0, width = 100, height = 80}
    e := create_enemy(rec, 500, 150, rl.BLACK)
    e.health = {
        current = 5,
        max = 500,
        take_dmg = take_damage,
    }
    data : Boss_Data
    data.abilities[0].is_available = true
    data.abilities[1].is_available = false
    a := &data.abilities[0]
    a.cooldown_timer = {
        cast_rate = 10,
    }
    a.cast_timer = {
        cast_rate = 5,
    }
    a.cast_visualizer ={
        tick = 0.2,
        draw = draw_reinforcment,
    }

    a.indicator = no_indicator_update
    a.activate = activate_reinforcement
    a.update = no_update
    a.finish = no_finish

    a.data = Reinforcment_Data{}

    b := &data.abilities[1]
    b.cooldown_timer.cast_rate = 3
    b.cast_timer.cast_rate = 1
    b.cast_visualizer.tick = 0.2
    b.cast_visualizer.draw = no_casting_draw

    b.indicator = no_indicator_update
    b.activate = activate_bombardment
    b.update = no_update
    b.finish = no_finish

    e.behavior = data
    e.knocback.apply = apply_no_knockback
    e.behave = test_boss_behavior
    e.on_death = on_death_boss
    return e
}

activate_bombardment :: proc(a : ^Ability, dt : f32){
    for _ in 0..<5{
        x := f32(rl.GetRandomValue(-150, 150))
        y := f32(rl.GetRandomValue(- 150, 150))
        pos := rl.Vector2 {game.player.pos.x + x, game.player.pos.y + y}
        p := Ability_Projectile{
            target_pos = pos,
            rec = {
                x = pos.x,
                y = pos.y - 1000,
                width = 10,
                height = 50,
            },
            speed = 900,
            dir = {0, 1},
            draw = draw_bombardment_projectiles,
        }
        append(&game.level.ability_projectiles, p)
    }
}

draw_bombardment_projectiles :: proc(p : Ability_Projectile){
    rl.DrawRectangleRec(p.rec, rl.BLACK)
    rl.DrawCircleV(p.target_pos, 60, {0, 0, 0, 100})
}

test_boss_behavior :: proc(e : ^Enemy, d : ^Behavior_Data, dt : f32){
    data := &d.(Boss_Data)

    if !can_boss_move(data^) do return
    dir := game.player.pos - {e.rec.x, e.rec.y}
    vel := rl.Vector2Normalize(dir) * e.speed
    new_pos : rl.Vector2 = {e.rec.x, e.rec.y}
    new_pos += vel * dt
    e.rec.x = new_pos.x
    e.rec.y = new_pos.y
}

can_boss_move :: proc(data : Boss_Data) -> bool{
    for a in data.abilities{
        if a.state == .Charging{
            return false
        }
    }
    return true
}