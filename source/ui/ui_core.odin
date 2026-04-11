package ui

import rl "vendor:raylib"

UI_Element :: union{
    UI_Cooldown,
    UI_Button,
    UI_Menu,
    UI_Progress_Bar,
    UI_Label,
    UI_Slider,
}
//Structs
//UI_Menu
Menu_Type :: enum{
    Pause, Main, Options,
}

UI_Menu :: struct{
    elements : [dynamic]UI_Element,
    width : f32,
    height : f32,
    color : rl.Color,
}
//UI_Button
Button_State :: enum{
    None, Focus, Pressing, Pressed
}

Button_Type :: enum{
    Continue, Options, Back, Exit
}

UI_Button :: struct{
    text : string,
    text_color : rl.Color,
    font_size : i32,
    color : rl.Color,
    n_color : rl.Color,
    f_color : rl.Color,
    p_color : rl.Color,
    pos : rl.Vector2,
    width : f32,
    height : f32,
    state : Button_State,
    type : Button_Type,
}

//UI Cooldown
UI_Cooldown :: struct{
    width : f32,
    height : f32,
    pos : rl.Vector2,
    value : f32,
    max : f32,
    icon : rl.Texture2D,
}

//UI_Label
UI_Label :: struct{
    text : string,
    pos : rl.Vector2,
    width : f32,
    height : f32,
    font_size : i32,
    text_color : rl.Color,
    color : rl.Color,
}

//UI_Progressbar
Bar_Type :: enum{
    Health, Value
}

UI_Progress_Bar :: struct{
    show_text : bool,
    min : f32,
    max : f32,
    value : f32,
    rect : rl.Rectangle,
    roundness : f32,
    segments : i32,
    outline_color : rl.Color,
    background_color : rl.Color,
    fill_color : rl.Color,
    type : Bar_Type,
}

//UI_Slider
Slider_state :: enum{
    None, Active
}

UI_Slider :: struct{
    pos : rl.Vector2,
    width : f32,
    height : f32,
    slider : rl.Rectangle,
    state : Slider_state,
    color : rl.Color,
    n_color : rl.Color,
    a_color : rl.Color,
}