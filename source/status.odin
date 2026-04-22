package game

import "core:fmt"
import rl "vendor:raylib"

Status_Type :: enum{Poison, Burn, Haste}
Status_State :: enum {None, Applied}

Apply_Status :: #type proc(e : any, s : ^Status_Effect, dt : f32)

Status_Effect :: struct{
    type : Status_Type,
    strength : f32,
    current_tick : f32,
    tick : f32,
    duration : f32,
    apply : Apply_Status,
    state : Status_State,
    texture : rl.Color,
    is_active : bool,
    create_particle : proc(particles : ^[dynamic]Particle, pos : rl.Vector2)
}

create_poison_status :: proc() -> Status_Effect{
    return {
        type = .Poison,
        strength = 2,
        tick = 0.5,
        duration = 5,
        apply = apply_poison,
        texture = rl.GREEN,
        create_particle = create_poison_particle,
        is_active = true,
    }
}

create_fire_status :: proc() -> Status_Effect{
    return {
        type = .Burn,
        strength = 5,
        tick = 0.25,
        duration = 2,
        apply = apply_fire,
        texture = rl.RED,
        create_particle = create_fire_particle,
        is_active = true,
    }
}

apply_poison :: proc(entity : any, poison : ^Status_Effect, dt : f32){
    
    if poison.duration <= 0{
        poison.is_active = false
    }
    
    if !poison.is_active do return
    
    poison.duration -= dt

    if poison.current_tick > 0{
        poison.current_tick -= dt
    } else{
        poison.current_tick = poison.tick
        poison.state = .Applied
        switch &c_entity in entity{
            case ^Player:
                c_entity.health->take_dmg(poison.strength)
            case ^Enemy:
                c_entity.health->take_dmg(poison.strength)
        }
    }
}

apply_fire :: proc(entity : any, fire : ^Status_Effect, dt : f32){
    if fire.duration <= 0{
        fire.is_active = false
    }

    if !fire.is_active do return

    fire.duration -= dt

    if fire.current_tick > 0{
        fire.current_tick -= dt
    } else{
        fire.current_tick = fire.tick
        fire.state = .Applied
        switch &e in entity{
            case ^Player:
                e.health->take_dmg(fire.strength)
            case ^Enemy:
                e.health->take_dmg(fire.strength)
        }
    }
}