package game

import rl "vendor:raylib"

Portal :: struct{
    pos : rl.Vector2,
    radius : f32,
    texture : rl.Texture2D,
    interact : Interactable,
    active : bool,
    animation : Animation,
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
        animation = {
            first_frame = 0,
            last_frame = 3,
            current_frame = 0,
            speed = 0.25,
            duration_left = 0.1,
            anim_direction = 1,
            mode = .Once,
        }
    }
    return p
}