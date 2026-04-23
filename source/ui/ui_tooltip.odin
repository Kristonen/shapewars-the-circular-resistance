package ui

import rl "vendor:raylib"

create_tooltip :: proc(pos : rl.Vector2) -> UI_ToolTip{
    return {
        rec = {
            x = pos.x,
            y = pos.y - 110,
            width = 100,
            height = 100,
        },
        color = {0, 0, 0, 100},
        is_active = false,
    }
}

create_text :: proc(text : string, color : rl.Color, font_size : i32) -> UI_Text{
    return {
        text = text,
        text_color = color,
        font_size = font_size,
    }
}