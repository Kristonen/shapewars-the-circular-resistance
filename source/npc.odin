package game

import rl "vendor:raylib"
import cl "collider"

NPC :: struct{
    pos : rl.Vector2,
    radius : f32,
    texture : rl.Color,
    interactable : Interactable,
}

create_test_npc :: proc(pos : rl.Vector2) -> NPC{
    n := NPC {
        pos = pos,
        radius = 30,
        texture = rl.BEIGE,
    }
    n.interactable = {
        text = "E - Interact",
        collider = {
            pos = n.pos,
            radius = n.radius * 2
        },
        action = test_interact,
    }
    
    return n
}