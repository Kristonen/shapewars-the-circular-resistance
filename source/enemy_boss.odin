package game

import "core:container/intrusive/list"
import rl "vendor:raylib"
import "ui"

Activate_Ability :: #type proc(e : ^Enemy)
Update_Ability :: #type proc(e : ^Enemy, dt : f32)
Finish_Ability :: #type proc(e : ^Enemy)
Cast_Ability :: #type proc(e : ^Enemy, dt : f32)

no_activate_enemy_ability :: proc(e : ^Enemy){}
no_update_enemy_ability :: proc(e : ^Enemy, dt : f32){}
no_finish_enemy_ability :: proc(e : ^Enemy){}

Boss_Ability :: struct{
    cd : Ability_Cooldown,
    data : Enemy_Ability_Data,
    cast_time : f32,
    cast_timer : f32,
    cast_ability : Cast_Ability,
    active : Activate_Ability,
    update : Update_Ability,
    finish : Finish_Ability,
    is_active : bool,
}

Enemy_Ability_Data :: union{
    Reinforcment_Data, Bombardment_Data
}

Reinforcment_Data :: struct{

}

Bombardment_Data :: struct{
    pos : rl.Vector2,
    radius : f32,
}

Boss_Data :: struct{
    abilities : [4]Boss_Ability,
    ability : Boss_Ability,
    is_casting : bool,
    current_cast : i32,
}

Test_Projectile :: struct {
    rec : rl.Rectangle,
    speed : f32,
    dir : rl.Vector2,
    target_pos : rl.Vector2,
}

call_reinforcement :: proc(b : ^Enemy, dt : f32){
    e := create_start_enemy()
    directions := []rl.Vector2 {{b.rec.x - 150, b.rec.y - 150}, {b.rec.x + 150, b.rec.y - 150}, {b.rec.x + 150, b.rec.y + 150}, {b.rec.x - 150, b.rec.y + 150}}
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
        append(&game.level.enemies, e)
    }
}

call_bombardment :: proc(b : ^Enemy, dt : f32){
    for _ in 0..<5{
        x := f32(rl.GetRandomValue(-150, 150))
        y := f32(rl.GetRandomValue(- 150, 150))
        pos := rl.Vector2 {game.player.pos.x + x, game.player.pos.y + y}
        p := Test_Projectile{
            target_pos = pos,
            rec = {
                x = pos.x,
                y = pos.y - 1000,
                width = 10,
                height = 50,
            },
            speed = 900,
            dir = {0, 1},
        }
        append(&game.level.ability_projectiles, p)
    }
}

test_boss_behavior :: proc(e : ^Enemy, d : ^Behavior_Data, dt : f32){
    data := &d.(Boss_Data)

    for i := 0; i < len(data.abilities);{
        a := &data.abilities[i]
        if !a.is_active{
            i += 1
            continue
        }
        if a.cd.cooldown > 0{
            a.cd.cooldown -= dt
            i += 1
            continue
        }

        if a.cd.cooldown <= 0 && !data.is_casting{
            a.cast_timer = a.cast_time
            data.is_casting = true
            data.current_cast = i32(i)
        }

        if i32(i) != data.current_cast{
            i += 1
            continue
        }

        if data.is_casting && a.cast_timer > 0{
            a.cast_timer -= dt
            i += 1
            continue
        }

        if data.is_casting && a.cast_timer <= 0{
            data.is_casting = false
            data.current_cast = -1
            a.cd.cooldown = a.cd.cast_rate
            a.cast_ability(e, dt)
            // a.active(e)
            // a.update(e, dt)
        }
        i += 1
    }

    if data.is_casting do return
    dir := game.player.pos - {e.rec.x, e.rec.y}
    vel := rl.Vector2Normalize(dir) * e.speed
    new_pos : rl.Vector2 = {e.rec.x, e.rec.y}
    new_pos += vel * dt
    e.rec.x = new_pos.x
    e.rec.y = new_pos.y
}