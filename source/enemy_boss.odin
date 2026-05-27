package game

import "core:math"
import "core:container/intrusive/list"
import rl "vendor:raylib"
import "ui"

Activate_Ability :: #type proc(e : ^Enemy, data : Enemy_Ability_Data)
Update_Ability :: #type proc(e : ^Enemy, dt : f32)
Finish_Ability :: #type proc(e : ^Enemy)
Draw_Ability :: #type proc(pos : rl.Vector2)
Cast_Ability :: #type proc(e : ^Enemy, dt : f32)

no_activate_enemy_ability :: proc(e : ^Enemy, data : Enemy_Ability_Data){}
no_update_enemy_ability :: proc(e : ^Enemy, dt : f32){}
no_finish_enemy_ability :: proc(e : ^Enemy){}
no_draw_enemy_ability :: proc(pos : rl.Vector2){}

Boss_Ability :: struct{
    cd : Ability_Cooldown,
    data : Enemy_Ability_Data,
    cast_time : f32,
    cast_timer : f32,
    cast_ability : Cast_Ability,
    active : Activate_Ability,
    update : Update_Ability,
    finish : Finish_Ability,
    casting_visualizer : Casting_Visualizer,
    is_useable : bool,
    is_active : bool,
}

Casting_Visualizer :: struct{
    tick : f32,
    current_tick : f32,
    draw : Draw_Ability,
    can_show : bool,
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

create_test_boss :: proc() -> Enemy{
    rec := rl.Rectangle{x = 0, y = 0, width = 100, height = 80}
    e := create_enemy(rec, 150, rl.BLACK)
    e.health = {
        current = 5,
        max = 500,
        take_dmg = take_damage,
    }
    e.knocback.apply = apply_no_knockback
    e.behave = test_boss_behavior
    data : Boss_Data
    data.abilities[0].is_useable = true
    data.abilities[0].cd.cast_rate = 10
    data.abilities[0].cast_time = 5
    data.abilities[0].active = activate_reinforcement
    data.abilities[0].update = no_update_enemy_ability
    data.abilities[0].casting_visualizer = {
        tick = 0.2,
        draw = draw_reinforcment,
    }

    data.abilities[1].is_useable = true
    data.abilities[1].cd.cast_rate = 2
    data.abilities[1].cast_time = 1
    data.abilities[1].active = activate_bombardment
    data.abilities[1].update = no_update_enemy_ability
    data.abilities[1].casting_visualizer.draw = no_draw_enemy_ability
    data.abilities[1].data = Bombardment_Data{
        radius = 60
    }

    data.current_cast = -1
    e.behavior = data
    e.on_death = on_death_boss
    return e
}

activate_reinforcement :: proc(b : ^Enemy, data : Enemy_Ability_Data){
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

activate_bombardment :: proc(b : ^Enemy, data : Enemy_Ability_Data){
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
            data = data
        }
        append(&game.level.ability_projectiles, p)
    }
}

draw_bombardment_projectiles :: proc(p : Ability_Projectile){
    data := p.data.(Bombardment_Data)
    rl.DrawRectangleRec(p.rec, rl.BLACK)
    rl.DrawCircleV(p.target_pos, data.radius, {0, 0, 0, 100})
}

test_boss_behavior :: proc(e : ^Enemy, d : ^Behavior_Data, dt : f32){
    data := &d.(Boss_Data)

    for i := 0; i < len(data.abilities);{
        a := &data.abilities[i]
        if !a.is_useable{
            i += 1
            continue
        }

        if a.is_active{
            a.update(e, dt)
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
            a.active(e, a.data)
            a.is_active = true
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