package game

import rl "vendor:raylib"

Portal :: struct{
    pos : rl.Vector2,
    radius : f32,
    interact : Interactable,
    active : bool,
}

create_portal :: proc(pos : rl.Vector2) -> Portal{
    p := Portal{
        pos = pos,
        radius = 32,
        interact = {
            action = portal_interact,
            text = "E - Use Portal",
            collider = {
                pos = pos,
                radius = 32 * 2,
            },
        },
        active = true,
    }
    return p
}