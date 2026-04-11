package game

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
    take_dmg : proc(h : ^Health, dmg : f32)
}

take_damage :: proc(h : ^Health, dmg : f32){
    h.current -= dmg
    if h.current <= h.min{
        h.current = h.min
        h.is_dead = true
    }
}