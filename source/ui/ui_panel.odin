package ui

import rl "vendor:raylib"

create_panel :: proc(rec : rl.Rectangle, color : rl.Color, alpha : u8 = 255) -> UI_Panel{
    return {
        rec = rec,
        color = {color.r, color.g, color.b, alpha},
        alpha = alpha,
    }
}