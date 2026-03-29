package game

import "core:fmt"
import rl "vendor:raylib"

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

update_health_bar :: proc(bar : ^Health_Bar, h : Health){

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

take_damage :: proc(b : Bullet, h : ^Health){
    h.current -= b.damage
    if h.current <= 0{
        h.current = h.min
        h.is_dead = true
    }
}