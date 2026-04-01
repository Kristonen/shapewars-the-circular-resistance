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

take_damage :: proc(b : bu.Bullet, h : ^Health){
    h.current -= b.damage
    if h.current <= 0{
        h.current = h.min
        h.is_dead = true
    }
}