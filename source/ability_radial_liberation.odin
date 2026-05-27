package game

import rl "vendor:raylib"
import "core:math"

Radial_Liberation_Data :: struct{
    amount : f32,
    dmg : f32,
    can_lifesteal : bool,
}

Radial_Liberation :: struct{
    damage : f32,
    count : f32,
    can_lifesteal : bool,
    ability_cd : Ability_Cooldown,
}

create_standard_radial_liberation :: proc() -> Ability{
    return {
        cd = {
            cast_rate = 5,
        },
        cast_timer = {
            cast_rate = 0,
        },
        indicator = no_indicator_update,
        activate = radial_liberation_activate,
        update = no_update,
        finish = no_finish,
        draw = no_draw,
        data = Radial_Liberation_Data{
            amount = 8,
            dmg = 5,
        },
    }
}

radial_liberation_activate :: proc(a : ^Ability, dt : f32){
    data := game.player.ability.data.(Radial_Liberation_Data)
    for i in 0..<data.amount{
        angle := f32(i) * (rl.PI * 2.0 / f32(data.amount))
        dir := rl.Vector2{
            math.cos(angle),
            math.sin(angle)
        }

        b := Bullet{
            damage = data.dmg,
            pos = game.player.pos,
            dir = dir,
            speed = 500,
            radius = 8,
            collider = {
                pos = game.player.pos,
                radius = 8,
            },
            is_active = true,
            can_lifesteal = data.can_lifesteal,
        }
        append(&game.level.player_bullets, b)
    }
    game.player.ability.active = false
}