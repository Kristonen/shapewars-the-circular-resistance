package ui

import rl "vendor:raylib"

Slider_state :: enum{
    None, Active
}

UI_Slider :: struct{
    pos : rl.Vector2,
    width : f32,
    height : f32,
    slider : rl.Rectangle,
    state : Slider_state,
    color : rl.Color,
    n_color : rl.Color,
    a_color : rl.Color,
}

create_slider :: proc(pos : rl.Vector2, size : rl.Vector2) -> UI_Slider{
    slider := UI_Slider{
        pos = pos,
        width = size.x,
        height = size.y,
        n_color = rl.LIME,
        a_color = rl.GOLD,
    }
    slider.pos.y += slider.height/2
    slider.slider = {
        x = slider.pos.x + slider.width/2,
        y = slider.pos.y - 15,
        width = 10,
        height = 30,
    }
    return slider
}

update_slider :: proc(s : ^UI_Slider){
    mouse_pos := rl.GetMousePosition()
    if rl.CheckCollisionPointRec(mouse_pos, s.slider) && rl.IsMouseButtonDown(.LEFT){
        s.state = .Active
    }
    //TODO Need imporvments!
    if rl.CheckCollisionPointLine(mouse_pos, s.pos, {s.pos.x + s.width, s.pos.y + s.height}, 20){
        if s.state == .None && rl.IsMouseButtonReleased(.LEFT){
            s.slider.x = mouse_pos.x
        }
    }

    if s.state == .Active && rl.IsMouseButtonReleased(.LEFT){
        s.state = .None
    }

    if s.state == .Active{
        if mouse_pos.x >= s.pos.x && mouse_pos.x <= s.pos.x + s.width{
            s.slider.x = mouse_pos.x
        }
    }
    update_slider_color(s)
}

update_slider_color :: proc(s : ^UI_Slider){
    switch s.state{
        case .None:
            s.color = s.n_color
        case .Active:
            s.color = s.a_color
    }
}

draw_slider :: proc(s : UI_Slider){
    end_pos := rl.Vector2{
        s.pos.x + s.width, s.pos.y
    }
    rl.DrawLineV(s.pos, end_pos, rl.RED)
    rl.DrawRectangleV({s.slider.x, s.slider.y}, {s.slider.width, s.slider.height}, s.color)
}