package ui

import rl "vendor:raylib"

create_menu :: proc(m : ^UI_Menu){
    m.width = f32(rl.GetScreenWidth())
    m.height = f32(rl.GetScreenHeight())
    m.color = {0, 0 ,0, 150}
}