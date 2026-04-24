package game

import rl "vendor:raylib"

NPC :: struct{
    pos : rl.Vector2,
    radius : f32,
    texture : rl.Color,
}

create_test_npc :: proc(pos : rl.Vector2) -> NPC{
    return {
        pos = pos,
        radius = 30,
        texture = rl.BEIGE,
    }
}