package ui

import "core:strings"
import rl "vendor:raylib"
import "core:fmt"

Bar_Type :: enum{
    Health, Value
}

UI_Progress_Bar :: struct{
    show_text : bool,
    min : f32,
    max : f32,
    value : f32,
    rect : rl.Rectangle,
    roundness : f32,
    segments : i32,
    outline_color : rl.Color,
    background_color : rl.Color,
    fill_color : rl.Color,
    type : Bar_Type,
}

update_progress_bar_player :: proc(p : ^UI_Progress_Bar, value : f32, max_value : f32){
    p.value = value
    p.max = max_value
}

update_progress_bar_enemy :: proc(p : ^UI_Progress_Bar, pos : rl.Vector2){
    p.rect.x = pos.x - 10
    p.rect.y = pos.y - 20
}

draw_progress_bar :: proc(p : UI_Progress_Bar){
    inner_p_bar, fill_p_bar := get_health_bars(p, 2.0)
    rl.DrawRectangleV({p.rect.x, p.rect.y}, {p.rect.width, p.rect.height}, p.outline_color)
    rl.DrawRectangleV({inner_p_bar.x, inner_p_bar.y}, {inner_p_bar.width, inner_p_bar.height}, p.background_color)
    rl.DrawRectangleV({fill_p_bar.x, fill_p_bar.y}, {fill_p_bar.width, fill_p_bar.height}, p.fill_color)

    if p.show_text{
        text := fmt.tprintf("%.0f/%.0f", p.value, p.max)
        font_size : i32 = 30
        ctext := strings.clone_to_cstring(text)
        text_width := rl.MeasureText(ctext, font_size)
        text_height : i32 = font_size
        text_x := i32(p.rect.x) + (i32(p.rect.width) - text_width) / 2
        text_y := i32(p.rect.y) + (i32(p.rect.height) - text_height) / 2
        rl.DrawText(ctext, i32(text_x), i32(text_y), font_size, rl.WHITE)
        delete(ctext)
    }
}

create_progress_bar :: proc(rect : rl.Rectangle, o_color, b_color, f_color : rl.Color) -> UI_Progress_Bar{
    bar : UI_Progress_Bar
    bar.rect = rect
    bar.outline_color = o_color
    bar.background_color = b_color
    bar.fill_color = f_color

    return bar
}

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