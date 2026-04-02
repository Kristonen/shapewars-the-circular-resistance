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

update_button :: proc(btn : ^UI_Button){
    mouse_pos := rl.GetMousePosition()
    rect := rl.Rectangle{
        x = btn.pos.x,
        y = btn.pos.y,
        width = btn.width,
        height = btn.height,
    }
    if rl.CheckCollisionPointRec(mouse_pos, rect){
        btn.state = .Focus

        if rl.IsMouseButtonDown(.LEFT){
            btn.state = .Pressing
        }
        if rl.IsMouseButtonReleased(.LEFT){
            btn.state = .Pressed
        }

    } else{
        btn.state = .None
    }
    update_button_color(btn)
}

update_button_color :: proc(btn : ^UI_Button){
    switch btn.state{
        case .None: btn.color = btn.n_color
        case .Focus: btn.color = btn.f_color
        case .Pressing: btn.color = btn.p_color
        case .Pressed: btn.color = rl.BLACK
    }
}

draw_button :: proc(btn : UI_Button){
    rect := rl.Rectangle{
        x = btn.pos.x,
        y = btn.pos.y,
        width = btn.width,
        height = btn.height,
    }
    rl.DrawRectangleV(btn.pos, {btn.width, btn.height}, btn.color)
    rl.DrawRectangleLinesEx(rect, 5, rl.BLACK)
    text := strings.clone_to_cstring(btn.text)
    text_width := rl.MeasureText(text, btn.font_size)
    text_height := btn.font_size
    text_x := i32(btn.pos.x) + (i32(btn.width) - text_width) / 2
    text_y := i32(btn.pos.y) + (i32(btn.height) - text_height) / 2
    rl.DrawText(text, i32(text_x), i32(text_y), 50, btn.text_color)
    delete_cstring(text)
}

