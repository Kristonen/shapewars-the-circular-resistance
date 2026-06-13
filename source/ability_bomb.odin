package game

import "core:fmt"
import rl "vendor:raylib"
import "handler"

BOMB_TIMER :: 3.0

Bomb_Data :: struct{
    damage : f32,
    speed : f32,
    timer : f32,
    radius : f32,
    explosion_radius : f32,
    pos : rl.Vector2,
    target_pos : rl.Vector2,
}

create_standard_bomb :: proc() -> Ability{
    return{
        cooldown_timer = {
            cast_rate = 1,
        },
        indicator = bomb_indicator_update,
        activate = bomb_activate,
        update = bomb_update,
        finish = bomb_finish,
        draw = bomb_draw,
        data = Bomb_Data{
            damage = 30,
            speed = 500,
            radius = 10,
            explosion_radius = 100,
            timer = 3,
        },
    }
}

bomb_indicator_update :: proc(a : ^Ability, dt : f32){
    data := &game.player.ability.data.(Bomb_Data)
    game.level.indicator = AoE_Indicator{
        radius = data.explosion_radius,
        pos = rl.GetScreenToWorld2D(rl.GetMousePosition(), game.camera),
    }
    if rl.IsMouseButtonPressed(.LEFT){
        a.state = .Charging
    }
}

bomb_activate :: proc(a : ^Ability, dt : f32){
    data := &game.player.ability.data.(Bomb_Data)
    indicator := game.level.indicator.(AoE_Indicator)
    data.target_pos = indicator.pos
    // data.target_pos = rl.GetScreenToWorld2D(rl.GetMousePosition(), game.camera)
    data.pos = game.player.pos
    game.level.indicator = nil
}

bomb_update :: proc(a : ^Ability, dt : f32){
    data := &game.player.ability.data.(Bomb_Data)

    dir := data.target_pos - data.pos
    dir = rl.Vector2Normalize(dir)
    if rl.Vector2Distance(data.pos, data.target_pos) > 1{
        data.pos += dir * data.speed * dt
        return
    }

    if data.timer > 0{
        data.timer -= dt
    } else {
        a.state = .Finished
    }
}

bomb_finish :: proc(a : ^Ability, dt : f32){
    data := &game.player.ability.data.(Bomb_Data)
    data.timer = BOMB_TIMER

    for &e in game.level.enemies{
        if e.health.is_dead do continue
        if rl.CheckCollisionCircleRec(data.pos, data.explosion_radius, e.rec){
            e->on_hit(data.damage)
        }
    }
    rec := rl.Rectangle{data.pos.x, data.pos.y, data.radius*2, data.radius*2}
    create_explosion_particles(rec)
}

bomb_draw :: proc(a : Ability){
    data := game.player.ability.data.(Bomb_Data)
    rl.DrawCircleV(data.pos, data.radius, rl.BEIGE)
}