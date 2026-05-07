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
Ability_Activate :: #type proc(dt : f32)
Ability_Finish :: #type proc(dt : f32)

Ability :: struct{
    cd : Ability_Cooldown,
    active : bool,
    activate : Ability_Activate,
    update : Ability_Update,
    finish : Ability_Finish,
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
        activate = radial_liberation_activate,
        update = no_update,
        finish = no_finish,
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
        finish = dash_finish,
        data = Dash_Data{
            speed = 3000,
        },
    }
}

no_activate :: proc(dt : f32){}
no_update :: proc(dt : f32){}
no_finish :: proc(dt : f32){}

dash_activate :: proc(dt : f32){
    data := &game.player.ability.data.(Dash_Data)
    data.dir = game.player.vel
    if data.dir.x == 0 && data.dir.y == 0{
        mouse_pos := rl.GetMousePosition()
        mouse_local_pos := rl.GetScreenToWorld2D(mouse_pos, game.camera)
        data.dir = rl.Vector2Normalize(mouse_local_pos - game.player.pos)
        game.player.health.invincible_timer = 0.2
    }
    data.timer = 0.2
}

dash_update :: proc(dt : f32){
    data := &game.player.ability.data.(Dash_Data)
    if data.timer > 0{
        create_dash_particle(game.player.pos, data.dir)
        game.player.pos += data.dir * data.speed * dt
        data.timer -= dt
        if game.player.ghost_timer > 0{
            game.player.ghost_timer -= dt
        } else{
            game.player.ghost_timer = Ghost_Time
            for i in 0..<len(game.player.ghosts){
                if game.player.ghosts[i].life > 0 do continue
                game.player.ghosts[i].pos = game.player.pos
                game.player.ghosts[i].life = 0.6
                break
            }
        }
    } else {
        game.player.ability.active = false
        dash_finish(dt)
    }
}

dash_finish :: proc(dt : f32){
    game.shake = 50

}

radial_liberation_activate :: proc(dt : f32){
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