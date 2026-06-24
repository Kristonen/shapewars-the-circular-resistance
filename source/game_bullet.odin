package game

import "core:fmt"
import rl "vendor:raylib"
import cl "collider"

Bullet :: struct {
    damage : f32,
    pos : rl.Vector2,
    dir : rl.Vector2,
    vel : rl.Vector2,
    speed : f32,
    radius : f32,
    collider : cl.Collider_Circle,
    can_lifesteal : bool,
    can_pierce : bool,
    hitted_enemies : [dynamic]rawptr,
    applied_status : [10]Status_Effect,

    is_active : bool,

    state : InGame_State,
}

create_bullet :: proc(radius : f32, speed : f32, dmg : f32) -> Bullet{
    b := Bullet{
        damage = dmg,
        radius = radius,
        speed = speed,
        is_active = true,
        can_lifesteal = true,
    }
    b.collider = {
        radius = b.radius,
    }
    return b
}

clear_bullet_status :: proc(){
    for i in 0..<len(game.player.weapon.bullet.applied_status){
        game.player.weapon.bullet.applied_status[i].game_state = .None
    }
}