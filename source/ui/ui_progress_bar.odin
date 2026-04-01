package ui

import rl "vendor:raylib"

UI_Progress_Bar :: struct{
    rect : rl.Rectangle,
    roundness : f32,
    segments : i32,
    outline_color : rl.Color,
    background_color : rl.Color,
    fill_color : rl.Color,
}

update_progress_bar :: proc(p : ^UI_Progress_Bar, pos : rl.Vector2){
    p.rect.x = pos.x - 10
    p.rect.y = pos.y - 20
}

draw_progress_bar :: proc(p : UI_Progress_Bar, c_health : f32, m_health : f32){
    inner_p_bar, fill_p_bar := get_health_bars(p.rect, c_health, m_health, 2.0)
    rl.DrawRectangleV({p.rect.x, p.rect.y}, {p.rect.width, p.rect.height}, p.outline_color)
    rl.DrawRectangleV({inner_p_bar.x, inner_p_bar.y}, {inner_p_bar.width, inner_p_bar.height}, p.background_color)
    rl.DrawRectangleV({fill_p_bar.x, fill_p_bar.y}, {fill_p_bar.width, fill_p_bar.height}, p.fill_color)
}

create_progress_bar :: proc(rect : rl.Rectangle, o_color, b_color, f_color : rl.Color) -> UI_Progress_Bar{
    bar : UI_Progress_Bar
    bar.rect = rect
    bar.outline_color = o_color
    bar.background_color = b_color
    bar.fill_color = f_color

    return bar
}

get_health_bars :: proc(rect : rl.Rectangle, c_health : f32, m_health : f32, margin : f32) -> (rl.Rectangle, rl.Rectangle){
    inner_health_bar := rect
    inner_health_bar.x += margin
    inner_health_bar.y += margin
    inner_health_bar.height -= margin * 2
    inner_health_bar.width -= margin * 2
    fill_health_bar := inner_health_bar
    fill_health_bar.width = (c_health/m_health) * inner_health_bar.width
    return inner_health_bar, fill_health_bar
}