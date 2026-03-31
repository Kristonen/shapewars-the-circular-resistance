package health

import rl "vendor:raylib"
import bu "../bullet"

Health_Bar :: struct{
    rect : rl.Rectangle,
    roundness : f32,
    segments : i32,
    outline_color : rl.Color,
    background_color : rl.Color,
    fill_color : rl.Color,
}

Health :: struct{
    current : f32,
    max : f32,
    min : f32,
    is_dead : bool,
}

update_health_bar :: proc(e_pos : rl.Vector2, bar : ^Health_Bar, h : Health){
    update_health_bar_pos(e_pos, &bar.rect)
}

update_health_bar_pos :: proc(pos : rl.Vector2, rect : ^rl.Rectangle){
    rect.x = pos.x - 10
    rect.y = pos.y - 20
}

draw_health_bar :: proc(bar : Health_Bar, h : Health){
    inner_health_bar := bar.rect
    margin : f32 = 2.0
    inner_health_bar.x += margin
    inner_health_bar.y += margin
    inner_health_bar.height -= margin * 2
    inner_health_bar.width -= margin * 2

    fill_health_bar := inner_health_bar
    fill_health_bar.width = (h.current/h.max) * bar.rect.width
    rl.DrawRectangleV({bar.rect.x, bar.rect.y}, {bar.rect.width, bar.rect.height}, bar.outline_color)
    rl.DrawRectangleV({inner_health_bar.x, inner_health_bar.y}, {inner_health_bar.width, inner_health_bar.height}, bar.background_color)
    rl.DrawRectangleV({fill_health_bar.x, fill_health_bar.y}, {fill_health_bar.width, fill_health_bar.height}, bar.fill_color)
}

create_health_bar :: proc(rect : rl.Rectangle, h : Health, o_color, b_color, f_color : rl.Color) -> Health_Bar{
    bar : Health_Bar

    rect := rl.Rectangle{
        x = rect.x - 10,
        y = rect.y - 20,
        width = rect.width + 20,
        height = 10,
    }

    bar.rect = rect
    bar.outline_color = o_color
    bar.background_color = b_color
    bar.fill_color = f_color

    return bar
}

get_health_bars :: proc(bar : Health_Bar, h :Health, margin : f32) -> (rl.Rectangle, rl.Rectangle){
    inner_health_bar := bar.rect
    inner_health_bar.x += margin
    inner_health_bar.y += margin
    inner_health_bar.height -= margin * 2
    inner_health_bar.width -= margin * 2

    fill_health_bar := inner_health_bar
    fill_health_bar.width = (h.current/h.max) * bar.rect.width

    return inner_health_bar, fill_health_bar
}

take_damage :: proc(b : bu.Bullet, h : ^Health){
    h.current -= b.damage
    if h.current <= 0{
        h.current = h.min
        h.is_dead = true
    }
}