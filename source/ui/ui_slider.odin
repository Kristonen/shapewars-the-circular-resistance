package ui

import rl "vendor:raylib"

create_slider :: proc(pos : rl.Vector2, size : rl.Vector2) -> UI_Slider{
    slider := UI_Slider{
        rec = {
            x = pos.x,
            y = pos.y,
            width = size.x,
            height = size.y,
        },
        n_color = rl.LIME,
        a_color = rl.GOLD,
    }
    slider.rec.y += slider.rec.height/2
    slider.slider = {
        x = slider.rec.x + slider.rec.width/2,
        y = slider.rec.y - 15,
        width = 10,
        height = 30,
    }
    return slider
}