package game

import rl "vendor:raylib"

Animation_Mode :: enum{
    Once, Loop, Ping_Pong,
}

Animation :: struct{
    first_frame : i32,
    last_frame : i32,
    current_frame : i32,
    speed : f32,
    duration_left : f32,

    mode : Animation_Mode,
    anim_direction : i32,
    is_finished : bool,
}

get_animation_frame :: proc(a : Animation, frames_per_frame : i32) -> rl.Rectangle{
    x := f32((a.current_frame % frames_per_frame)*32)
    y := f32((a.current_frame / frames_per_frame)*32)

    return {
        x = x,
        y = y,
        width = 32,
        height = 32,
    }
}