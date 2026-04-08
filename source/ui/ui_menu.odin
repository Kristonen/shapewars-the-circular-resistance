package ui

import rl "vendor:raylib"
import "core:fmt"

Menu_Type :: enum{
    Pause, Main, Options,
}

UI_Menu :: struct{
    elements : [dynamic]UI_Element,
    width : f32,
    height : f32,
    color : rl.Color,
}

create_menu :: proc(m : ^UI_Menu){
    m.width = f32(rl.GetScreenWidth())
    m.height = f32(rl.GetScreenHeight())
    m.color = {0, 0 ,0, 150}
}