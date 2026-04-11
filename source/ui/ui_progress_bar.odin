package ui

import rl "vendor:raylib"

create_progress_bar :: proc(rect : rl.Rectangle, o_color, b_color, f_color : rl.Color) -> UI_Progress_Bar{
    bar : UI_Progress_Bar
    bar.rect = rect
    bar.outline_color = o_color
    bar.background_color = b_color
    bar.fill_color = f_color

    return bar
}
//TODO instead of creating 3 different rectangles use the black one for DrawRectangleLinesEX
get_health_bars :: proc(p : UI_Progress_Bar, margin : f32) -> (rl.Rectangle, rl.Rectangle){
    inner_health_bar := p.rect
    inner_health_bar.x += margin
    inner_health_bar.y += margin
    inner_health_bar.height -= margin * 2
    inner_health_bar.width -= margin * 2
    fill_health_bar := inner_health_bar
    fill_health_bar.width = (p.value/p.max) * inner_health_bar.width
    return inner_health_bar, fill_health_bar
}