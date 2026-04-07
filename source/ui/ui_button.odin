package ui

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Button_Proc :: #type proc()

Button_State :: enum{
    None, Focus, Pressing, Pressed
}

Button_Type :: enum{
    Continue, Options, Back, Exit
}

UI_Button :: struct{
    text : string,
    text_color : rl.Color,
    font_size : i32,
    color : rl.Color,
    n_color : rl.Color,
    f_color : rl.Color,
    p_color : rl.Color,
    pos : rl.Vector2,
    width : f32,
    height : f32,
    state : Button_State,
    type : Button_Type,
}

create_button :: proc(text : string, pos : rl.Vector2, size : rl.Vector2) -> UI_Button{
    return {
        text = text,
        pos = {pos.x, pos.y},
        width = size.x,
        height = size.y,
        font_size = 50,
        text_color = rl.WHITE,
        n_color = rl.BROWN,
        color = rl.BROWN,
        f_color = rl.BEIGE,
        p_color = rl.VIOLET,
        state = .None
    }
}

