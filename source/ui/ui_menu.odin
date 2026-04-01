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

create_menu :: proc(type : Menu_Type) -> UI_Menu{
    menu : UI_Menu
    switch type{
        case .Pause:
            menu = create_pause_menu()
            create_buttons_for_pause_menu(&menu)
        case.Main:
        case .Options:
            menu = create_options_menu()
            create_option_stuff(&menu)
    }
    return menu
}

create_pause_menu :: proc() -> UI_Menu{
    color := rl.Color{0, 0, 0, 100}
    return {
        width = f32(rl.GetScreenWidth()),
        height = f32(rl.GetScreenHeight()),
        color = color,
    }
}

create_options_menu :: proc() -> UI_Menu{
    color := rl.Color{0, 0, 0, 100}
    return {
        width = f32(rl.GetScreenWidth()),
        height = f32(rl.GetScreenHeight()),
        color = color,
    }
}

update_menu :: proc(menu : ^UI_Menu){
    for &element in menu.elements{
        switch &e in element{
            case UI_Button:
                update_button(&e)
            case UI_Cooldown:
            case UI_Menu:
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
        }
    }
}