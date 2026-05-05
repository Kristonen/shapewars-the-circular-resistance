package game

import "core:math"
import rl "vendor:raylib"

Ability_Data :: union {
    Radial_Liberation_Data, Dash_Data
}

Radial_Liberation_Data :: struct{
    amount : f32,
    dmg : f32,
    can_lifesteal : bool,
}

Dash_Data :: struct{
    dir : rl.Vector2,
    speed : f32,
    timer : f32,
}

Ability_Update :: #type proc(dt : f32)
Ability_Activate :: #type proc()

Ability :: struct{
    cd : Ability_Cooldown,
    active : bool,
    activate : Ability_Activate,
    update : Ability_Update,
    data : Ability_Data,
}

Ability_Cooldown :: struct{
    cooldown : f32,
    timer : f32,
    cast_rate : f32,
}

create_standard_radial_liberation :: proc() -> Ability{
    return {
        cd = {
            cast_rate = 5,
        },
        activate = no_activate,
        update = radial_liberation_update,
        data = Radial_Liberation_Data{
            amount = 8,
            dmg = 5,
        },
    }
}

create_standard_dash :: proc() -> Ability{
    return{
        cd = {
            cast_rate = 3,
        },
        activate = dash_activate,
        update = dash_update,
        data = Dash_Data{
            speed = 3000,
        },
    }
}

no_activate :: proc(){}

dash_activate :: proc(){
    data := &game.player.ability.data.(Dash_Data)
    data.dir = game.player.vel
    if data.dir.x == 0 && data.dir.y == 0{
        mouse_pos := rl.GetMousePosition()
        mouse_local_pos := rl.GetScreenToWorld2D(mouse_pos, game.camera)
        data.dir = rl.Vector2Normalize(mouse_local_pos - game.player.pos)
    }
    data.timer = 0.2
}

radial_liberation_update :: proc(dt : f32){
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

dash_update :: proc(dt : f32){
    data := &game.player.ability.data.(Dash_Data)
    if data.timer > 0{
        game.player.pos += data.dir * data.speed * dt
        data.timer -= dt
    } else {
        game.player.ability.active = false
    }
}