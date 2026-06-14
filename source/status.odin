package game

import "core:fmt"
import rl "vendor:raylib"

Status_Type :: enum{Poison, Burn, Haste, Bleed, Confused}
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
    create_particle : proc(area : rl.Rectangle)
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

create_fire_status :: proc(strength : f32, tick : f32, duration : f32) -> Status_Effect{
    return {
        type = .Burn,
        strength = strength,
        tick = tick,
        duration = duration,
        apply = apply_fire,
        texture = rl.RED,
        create_particle = create_fire_particle,
        is_active = true,
    }
}

create_bleed_status :: proc(strength : f32, tick : f32, duration : f32) -> Status_Effect{
    return {
        type = .Bleed,
        strength = strength,
        tick = tick,
        duration = duration,
        apply = apply_bleed,
        texture = rl.RED,
        create_particle = create_bleeding_particle,
        is_active = true,
    }
}

create_confused_status :: proc(strength : f32, tick : f32, duration : f32) -> Status_Effect{
    return{
        type = .Confused,
        strength = strength,
        tick = tick,
        duration = duration,
        apply = apply_confused,
        texture = rl.WHITE,
        create_particle = create_confused_particle,
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

apply_confused :: proc(entity : any, confused : ^Status_Effect, dt : f32){
    if confused.duration <= 0{
        confused.is_active = false
    }

    if !confused.is_active do return

    confused.duration -= dt

    if confused.current_tick > 0{
        confused.current_tick -= dt
    } else{
        confused.current_tick = confused.tick
        confused.state = .Applied
        switch &e in entity{
            case ^Player:
                e.health->take_dmg(confused.strength)
            case ^Enemy:
                e.health->take_dmg(confused.strength)
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

apply_bleed :: proc(entity : any, bleed : ^Status_Effect, dt : f32){
    if bleed.duration <= 0{
        bleed.is_active = false
    }

    if !bleed.is_active do return

    bleed.duration -= dt

    if bleed.current_tick > 0{
        bleed.current_tick -= dt
    } else{
        bleed.current_tick = bleed.tick
        bleed.state = .Applied
        switch &e in entity{
            case ^Player:
                e.health->take_dmg(bleed.strength)
            case ^Enemy:
                e.health->take_dmg(bleed.strength)
        }
    }
}