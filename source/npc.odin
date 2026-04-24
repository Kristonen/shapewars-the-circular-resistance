package game

import rl "vendor:raylib"
import cl "collider"

NPC :: struct{
    pos : rl.Vector2,
    radius : f32,
    texture : rl.Color,
    interaction_collider : cl.Collider_Circle,
}

create_test_npc :: proc(pos : rl.Vector2) -> NPC{
    n := NPC {
        pos = pos,
        radius = 30,
        texture = rl.BEIGE,
    }
    n.interaction_collider = {
        pos = n.pos,
        radius = n.radius * 1.1
    }
    
    return n
}