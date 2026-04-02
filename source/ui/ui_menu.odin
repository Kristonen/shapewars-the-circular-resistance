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
    m.color = {0, 0, 0, 100}
}

create_menu_elements :: proc(elements : ^[dynamic]UI_Element, type : Menu_Type){
    clear(elements)
    switch type{
        case .Pause:
        case .Options:
        case .Main:
    }
}

update_menu :: proc(menu : ^UI_Menu){
    for &element in menu.elements{
        switch &e in element{
            case UI_Button:
                update_button(&e)
            case UI_Cooldown:
            case UI_Menu:
            case UI_Progress_Bar:
            case UI_Label:
                update_label(&e)
            case UI_Slider:
                update_slider(&e)
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
            case UI_Progress_Bar:
                //
            case UI_Label:
                draw_label(e)
            case UI_Slider:
                draw_slider(e)
        }
    }
}