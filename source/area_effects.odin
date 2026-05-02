package game

import rl "vendor:raylib"

Area_Effect :: struct{
    pos : rl.Vector2,
    radius : f32,
    duration : f32,
    trigger : proc(a : Area_Effect, e : ^Entity)
}

on_area_poison_trigger :: proc(a : Area_Effect, entity : ^Entity){
    switch &e in entity {
        case Player:
            s := create_poison_status()
            if idx := check_if_entity_already_got_status(e.statuses, s); idx == -1{
                append(&e.statuses, s)
            } else{
                e.statuses[idx].duration = s.duration
            }
        case Enemy:
            s := create_poison_status()
            if idx := check_if_entity_already_got_status(e.statuses, s); idx == -1{
                append(&e.statuses, s)
            } else{
                e.statuses[idx].duration = s.duration
            }
    }
}