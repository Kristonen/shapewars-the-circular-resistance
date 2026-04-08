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