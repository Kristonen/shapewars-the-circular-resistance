package game

import "core:fmt"
import rl "vendor:raylib"

Status_Desc :: enum{Poison, Burn, Haste, Bleed, Confused}
Status_State :: enum {None, Applied}

Status_Type :: union{
    TickStatus, OneTimeStatus
}

Activate_Status :: #type proc(e : any, s : ^Status_Effect, dt : f32)
Update_Status :: #type proc(e : any, s : ^Status_Effect, dt : f32)
Finish_Status :: #type proc(e : any, s : ^Status_Effect, dt : f32)
Status_Proc :: #type proc(e : any, s : ^Status_Effect, dt : f32)
Status_Particle :: #type proc(area : rl.Rectangle)

Status_Effect :: struct{
    desc : Status_Desc,
    type : Status_Type,
    // apply : Update_Status,
    state : Status_State,
    texture : rl.Color,
    is_active : bool,
    create_particle : Status_Particle,
}

TickStatus :: struct{
    current_tick : f32,
    tick : f32,
    duration : f32,
    activate : Status_Proc,
    apply : Status_Proc,
    finish : Status_Proc,
    strength : f32,
}

OneTimeStatus :: struct{
    strength : f32,
    activate : Activate_Status,
    finish : Finish_Status,
}

create_poison_status :: proc(strength, tick, duration : f32) -> Status_Effect{
    s:= create_tick_status(strength, tick, duration, .Poison, nil, tick_status_damage_update, nil)
    return s
//     return {
//         desc = .Poison,
//         type = TickStatus{
//             strength = 2,
//             tick = 0.5,
//             duration = 5,
//             activate = {},
//             apply = tick_status_damage_update,
//             finish = {},
//         },
//         // apply = apply_poison,
//         texture = rl.GREEN,
//         create_particle = create_poison_particle,
//         is_active = true,
//     }
}

create_tick_status :: proc(strength, tick, duration : f32, desc : Status_Desc, activate, apply, finish : Status_Proc) -> Status_Effect{
    s := Status_Effect{
        desc = desc,
        type = TickStatus{
            strength = strength,
            tick = tick,
            duration = duration,
            activate = activate,
            apply = apply,
            finish = finish,
        },
        is_active = true,
    }
    switch desc{
        case .Poison:
            s.create_particle = create_poison_particle
        case .Burn:
            s.create_particle = create_fire_particle
        case .Haste:
        case .Bleed:
            s.create_particle = create_bleeding_particle
        case .Confused:
            s.create_particle = create_confused_particle
    }
    return s
}

create_fire_status :: proc(strength, tick, duration : f32) -> Status_Effect{
    return create_tick_status(strength, tick, duration, .Burn, nil, tick_status_damage_update, nil)
//     return {
//         desc = .Burn,
//         strength = strength,
//         tick = tick,
//         duration = duration,
//         // apply = apply_fire,
//         texture = rl.RED,
//         create_particle = create_fire_particle,
//         is_active = true,
//     }
}

create_bleed_status :: proc(strength, tick, duration : f32) -> Status_Effect{
    return create_tick_status(strength, tick, duration, .Bleed, nil, tick_status_damage_update, nil)
//     return {
//         desc = .Bleed,
//         strength = strength,
//         tick = tick,
//         duration = duration,
//         // apply = apply_bleed,
//         texture = rl.RED,
//         create_particle = create_bleeding_particle,
//         is_active = true,
//     }
}

create_confused_status :: proc(strength : f32, tick : f32, duration : f32) -> Status_Effect{
    return{
        desc = .Confused,
        // apply = apply_confused,
        texture = rl.WHITE,
        create_particle = create_confused_particle,
        is_active = true,
    }
}

tick_status_damage_update :: proc(e : any, s : ^Status_Effect, dt : f32){
    s.state = .None
    tick_status := s.type.(TickStatus)
    switch &entity in e{
        case ^Player:
            entity.health->take_dmg(tick_status.strength)
        case ^Enemy:
            entity.health->take_dmg(tick_status.strength)
    }
}

apply_confused :: proc(entity : any, confused : ^Status_Effect, dt : f32){
    
}