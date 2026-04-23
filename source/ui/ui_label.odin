package ui

import rl "vendor:raylib"

create_label :: proc(text : string, pos : rl.Vector2, size : rl.Vector2) -> UI_Label{
    return {
        text = {
            content = text,
            font_size = 50,
            text_color = rl.WHITE,
        },
        rec = {
            x = pos.x,
            y = pos.y,
            width = size.x,
            height = size.y,
        },
        color = rl.GRAY,
    }
}