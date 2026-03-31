package ui

import rl "vendor:raylib"
import "core:fmt"

Menu_Type :: enum{
    Pause, Main
}

UI_Menu :: struct{
    elements : [dynamic]UI_Element,
    width : f32,
    height : f32,
    color : rl.Color
}

create_pause_menu :: proc(type : Menu_Type) -> UI_Menu{
    color := rl.Color{0, 0, 0, 100}
    return {
        width = f32(rl.GetScreenWidth()),
        height = f32(rl.GetScreenHeight()),
        color = color,
        elements = create_button(type)
    }
}

update_menu :: proc(menu : ^UI_Menu){
    for &element in menu.elements{
        switch &e in element{
            case UI_Button: 
                update_button(&e)
            case UI_Cooldown:
            case UI_Menu:
            case:
        }
    }
}

draw_menu :: proc(menu : UI_Menu){
    rl.DrawRectangleV({0, 0}, {menu.width, menu.height}, menu.color)
    for element in menu.elements{
        switch e in element{
            case UI_Button:
                draw_button(e)
            case UI_Cooldown:
                //
            case UI_Menu:
                //
            case:
        }
    }
}