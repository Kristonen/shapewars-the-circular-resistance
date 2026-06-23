package game

import rl "vendor:raylib"
import cl "collider"

NPC :: struct{
    pos : rl.Vector2,
    radius : f32,
    texture : rl.Color,
    interactable : Interactable,
    state : InGame_State,
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

create_catalyst_npc :: proc(pos: rl.Vector2) -> NPC{
    n := NPC{
        pos = pos,
        radius = 26,
        texture = rl.DARKGREEN,
    }
    n.interactable = {
        text = "E - Catalyst",
        collider = {
            pos = pos,
            radius = n.radius * 2,
        },
        action = catalyst_interact
    }
    return n
}

create_quartermaster_npc :: proc(pos : rl.Vector2) -> NPC{
    n := NPC{
        pos = pos,
        radius = 28,
        texture = rl.RED,
    }
    n.interactable = {
        text = "E - Quartermaster",
        collider = {
            pos = pos,
            radius = n.radius * 2,
        },
        action = quartermaster_interact,
    }
    return n
}

create_craftman_npc :: proc(pos : rl.Vector2) -> NPC{
    n := NPC{
        pos = pos,
        radius = 20,
        texture = rl.BEIGE,
    }
    n.interactable = {
        text = "E - Craftman",
        collider = {
            pos = pos,
            radius = n.radius * 2,
        },
        action = craftman_interact,
    }
    return n
}