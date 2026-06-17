package game

import rl "vendor:raylib"

Area_Effect :: struct{
    pos : rl.Vector2,
    radius : f32,
    duration : f32,
    max_duration : f32,
    trigger : proc(a : Area_Effect, e : ^Entity)
}

on_area_poison_trigger :: proc(a : Area_Effect, entity : ^Entity){
    s := create_poison_status(4, 0.5, 4)
    switch &e in entity {
        case Player:
            // s := create_poison_status()
            if idx, ok := check_if_entity_already_got_status(e.statuses, s); !ok{
                append(&e.statuses, s)
            } else{
                overwriting_status := &e.statuses[idx].type.(TickStatus)
                tick_status := s.type.(TickStatus)
                s.duration = s.duration
            }
        case Enemy:
            // s := create_poison_status()
            if idx, ok := check_if_entity_already_got_status(e.statuses, s); !ok{
                append(&e.statuses, s)
            } else{
                overwriting_status := &e.statuses[idx].type.(TickStatus)
                tick_status := s.type.(TickStatus)
                s.duration = s.duration
            }
    }
}