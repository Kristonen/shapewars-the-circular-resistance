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
    on_click : proc(),
}

create_buttons_for_pause_menu :: proc(m : ^UI_Menu){
    play_btn := get_standard_button()
    play_btn.text = "Continue"
    play_btn.type = .Continue

    opt_btn := play_btn
    opt_btn.text = "Options"
    opt_btn.pos.y += opt_btn.height * 2 + 50
    opt_btn.type = .Options
    
    esc_btn := opt_btn
    esc_btn.text = "Exit"
    esc_btn.pos.y += esc_btn.height * 2 + 50
    esc_btn.type = .Exit

    append(&m.elements, play_btn)
    append(&m.elements, opt_btn)
    append(&m.elements, esc_btn)
}

create_option_stuff :: proc(m : ^UI_Menu){
    back_btn := get_standard_button()
    back_btn.pos.y = f32(rl.GetScreenHeight()) * 0.85
    back_btn.text = "Back"
    back_btn.type = .Back

    append(&m.elements, back_btn)
}

get_standard_button :: proc() -> UI_Button{
    btn : UI_Button
    btn.text = "Continue"
    btn.width = 500
    btn.height = 100
    btn.text_color = rl.WHITE
    btn.font_size = 50
    btn.n_color = rl.BROWN
    btn.f_color = rl.BEIGE
    btn.p_color = rl.VIOLET
    btn.color = btn.n_color
    pos_x := f32(rl.GetScreenWidth()) / 2 - btn.width / 2
    pos_y := f32(rl.GetScreenHeight()) / 2 - btn.width / 2
    btn.pos = {pos_x, pos_y}
    btn.state = .None
    return btn
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
    rl.DrawRectangleV(btn.pos, {btn.width, btn.height}, btn.color)
    text := strings.clone_to_cstring(btn.text)
    text_width := rl.MeasureText(text, btn.font_size)
    text_height := btn.font_size
    text_x := i32(btn.pos.x) + (i32(btn.width) - text_width) / 2
    text_y := i32(btn.pos.y) + (i32(btn.height) - text_height) / 2
    rl.DrawText(text, i32(text_x), i32(text_y), 50, btn.text_color)
    delete_cstring(text)
}

