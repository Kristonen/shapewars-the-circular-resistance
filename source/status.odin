package game

import "core:fmt"
import rl "vendor:raylib"

Status_Desc :: enum{Poison, Burn, Haste, Bleed, Confused}
Status_State :: enum {None, Applied, Active, Finished}

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
    duration : f32,
    // apply : Update_Status,
    state : Status_State,
    texture : rl.Color,
    is_active : bool,
    create_particle : Status_Particle,
}

TickStatus :: struct{
    current_tick : f32,
    tick : f32,
    activate : Status_Proc,
    apply : Status_Proc,
    finish : Status_Proc,
    strength : f32,
}

OneTimeStatus :: struct{
    base_state : f32,
    strength : f32,
    activate : Activate_Status,
    finish : Finish_Status,
}

create_tick_status :: proc(strength, tick, duration : f32, desc : Status_Desc, activate, apply, finish : Status_Proc) -> Status_Effect{
    s := Status_Effect{
        desc = desc,
        duration = duration,
        type = TickStatus{
            strength = strength,
            tick = tick,
            activate = activate,
            apply = apply,
            finish = finish,
        },
        is_active = true,
    }
    set_particle_to_status(&s)
    
    return s
}

create_onetime_status :: proc(strength, duration : f32, desc : Status_Desc, activate, finish : Status_Proc) -> Status_Effect{
    s := Status_Effect{
        desc = desc,
        duration = duration,
        type = OneTimeStatus{
            strength = strength,
            activate = activate,
            finish = finish,
        },
        is_active = true,
    }
    set_particle_to_status(&s)

    return s
}

set_particle_to_status :: proc(s : ^Status_Effect){
    switch s.desc{
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
}

create_poison_status :: proc(strength, tick, duration : f32) -> Status_Effect{
    return create_tick_status(strength, tick, duration, .Poison, nil, tick_status_damage_update, nil)
}

create_fire_status :: proc(strength, tick, duration : f32) -> Status_Effect{
    return create_tick_status(strength, tick, duration, .Burn, nil, tick_status_damage_update, nil)
}

create_bleed_status :: proc(strength, tick, duration : f32) -> Status_Effect{
    return create_tick_status(strength, tick, duration, .Bleed, nil, tick_status_damage_update, nil)
}

create_confused_status :: proc(strength, duration : f32) -> Status_Effect{
    return create_onetime_status(strength, duration, .Confused, activate_confused, finish_confused)
}

tick_status_damage_update :: proc(e : any, s : ^Status_Effect, dt : f32){
    tick_status := s.type.(TickStatus)
    switch &entity in e{
        case ^Player:
            entity.health->take_dmg(tick_status.strength)
        case ^Enemy:
            entity.health->take_dmg(tick_status.strength)
    }
}

activate_confused :: proc(entity : any, confused : ^Status_Effect, dt : f32){
    rec := get_rec_from_entity(entity)
    confused.create_particle(rec)
    onetime_status := &confused.type.(OneTimeStatus)
    switch &e in entity{
        case ^Player:
            onetime_status.base_state = e.speed
            e.speed -= onetime_status.strength
            e.health->take_dmg(10)
        case ^Enemy:
            onetime_status.base_state = e.speed
            e.speed -= onetime_status.strength
            e.health->take_dmg(10)
    }

}

finish_confused :: proc(entity : any, confused : ^Status_Effect, dt : f32){
    onetime_status := &confused.type.(OneTimeStatus)
    switch &e in entity{
        case ^Player:
            e.speed = onetime_status.base_state
        case ^Enemy:
            e.speed = onetime_status.base_state
    }
}

give_entity_status :: proc{
    give_player_status,
    give_enemy_status,
}

give_player_status :: proc(statuses : []Status_Effect, attacked : ^Player){
    for s in statuses{
        if idx, ok := check_if_entity_already_got_status(attacked.statuses, s); !ok{
            idx, err := append(&attacked.statuses, s)
            attacked.statuses[idx - 1].state = .Applied
            
        } else{
            attacked.statuses[idx].duration = s.duration
        }
    }
}

give_enemy_status :: proc(statuses : []Status_Effect, attacked : ^Enemy){
    for s in statuses{
        if idx, ok := check_if_entity_already_got_status(attacked.statuses, s); !ok{
            idx, err := append(&attacked.statuses, s)
            attacked.statuses[idx - 1].state = .Applied
        } else{
            attacked.statuses[idx].duration = s.duration
        }
    }
}

check_if_entity_already_got_status :: proc(s_array : [dynamic]Status_Effect, s : Status_Effect) -> (i32, bool){
    for e_s, idx in s_array{
        if e_s.desc == s.desc do return i32(idx), true
    }
    return -1, false
}