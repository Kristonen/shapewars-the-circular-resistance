package game

import rl "vendor:raylib"
import cl "collider"

NPC :: struct{
    pos : rl.Vector2,
    radius : f32,
    texture : rl.Color,
    interactable : Interactable,
}

create_gunsmith_npc :: proc(pos : rl.Vector2) -> NPC{
    n := NPC {
        pos = pos,
        radius = 30,
        texture = rl.BEIGE,
    }
    n.interactable = {
        text = "E - Gunsmith",
        collider = {
            pos = n.pos,
            radius = n.radius * 2
        },
        action = gunsmith_interact,
    }
    
    return n
}

create_commander_npc :: proc(pos : rl.Vector2) -> NPC{
    n := NPC{
        pos = pos,
        radius = 36,
        texture = rl.BLACK,
    }
    n.interactable = {
        text = "E - Commander",
        collider = {
            pos = pos,
            radius = n.radius * 2
        },
        action = commander_interact,
    }
    return n
}