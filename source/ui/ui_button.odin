package ui

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Button_State :: enum{
    None, Focus, Press
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
}

create_button :: proc(type : Menu_Type) -> [dynamic]UI_Element{
    btns := make([dynamic]UI_Element)
    play_btn : UI_Button

    play_btn.text = "Continue"
    play_btn.width = 500
    play_btn.height = 100
    play_btn.text_color = rl.WHITE
    play_btn.font_size = 50
    play_btn.n_color = rl.BROWN
    play_btn.f_color = rl.BEIGE
    play_btn.color = play_btn.n_color
    pos_x := f32(rl.GetScreenWidth()) / 2 - play_btn.width / 2
    pos_y := f32(rl.GetScreenHeight()) / 2 - play_btn.width / 2
    play_btn.pos = {pos_x, pos_y}
    play_btn.state = .None

    opt_btn := play_btn
    opt_btn.text = "Options"
    opt_btn.pos.y += opt_btn.height * 2 + 50
    
    esc_btn := opt_btn
    esc_btn.text = "Exit"
    esc_btn.pos.y += esc_btn.height * 2 + 50

    append(&btns, play_btn)
    append(&btns, opt_btn)
    append(&btns, esc_btn)
    return btns
}

update_button :: proc(btn : ^UI_Button){
    mouse_pos := rl.GetMousePosition()
    rect := rl.Rectangle{
        x = btn.pos.x,
        y = btn.pos.y,
        width = btn.width,
        height = btn.height,
    }
    // if btn.text == "Continue"{
    //     fmt.printfln("Mouse pos: %d | %d", mouse_pos.x, mouse_pos.y)
    //     fmt.printfln("Btn pos: %d | %d", btn.pos.x, btn.pos.y)
    // }
    if rl.CheckCollisionPointRec(mouse_pos, rect){
        btn.state = .Focus
    } else{
        btn.state = .None
    }
    update_button_color(btn)
}

update_button_color :: proc(btn : ^UI_Button){
    switch btn.state{
        case .None: btn.color = btn.n_color
        case .Focus: btn.color = btn.f_color
        case .Press: btn.color = btn.p_color
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

