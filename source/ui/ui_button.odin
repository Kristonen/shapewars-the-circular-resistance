package ui

import rl "vendor:raylib"

Button_Proc :: #type proc()

create_button :: proc(text : string, pos : rl.Vector2, size : rl.Vector2) -> UI_Button{
    return {
        text = text,
        rec = {
            x = pos.x,
            y = pos.y,
            width = size.x,
            height = size.y,
        },
        font_size = 50,
        text_color = rl.WHITE,
        n_color = rl.BROWN,
        color = rl.BROWN,
        f_color = rl.BEIGE,
        p_color = rl.VIOLET,
        state = .None
    }
}

