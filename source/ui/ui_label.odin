package ui

import "core:strings"
import rl "vendor:raylib"

UI_Label :: struct{
    text : string,
    pos : rl.Vector2,
    width : f32,
    height : f32,
    font_size : i32,
    text_color : rl.Color,
    color : rl.Color,
}

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