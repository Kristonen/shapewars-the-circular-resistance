package ui

import rl "vendor:raylib"

create_label :: proc(text : string, pos : rl.Vector2, size : rl.Vector2) -> UI_Label{
    return {
        text = text,
        pos = pos,
        width = size.x,
        height = size.y, 
        font_size = 50,
        text_color = rl.WHITE,
        color = rl.GRAY,
    }
}