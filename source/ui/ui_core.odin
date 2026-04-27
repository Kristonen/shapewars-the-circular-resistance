package ui

import rl "vendor:raylib"

UI_Element :: union{
    UI_Cooldown,
    UI_Button,
    UI_Menu,
    UI_Progress_Bar,
    UI_Label,
    UI_Slider,
    UI_Status_Bar,
}
//Structs
//UI_Menu
Menu_Type :: enum{
    Pause, Main, Options, Gunsmith, Skilltree, ChooseLevel
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
    Continue, Options, Back, Exit, Skilltree
}

UI_Button :: struct{
    text : UI_Text,
    text_color : rl.Color,
    font_size : i32,
    color : rl.Color,
    n_color : rl.Color,
    f_color : rl.Color,
    p_color : rl.Color,
    rec : rl.Rectangle,
    state : Button_State,
    type : Button_Type,

    storage : u64,
    data : any,

    on_click : On_Click,
}

//UI Skill Tree
UI_Node_State :: enum{None, Focussed, Pressed}
UI_Skill_Tree_Type :: enum {NormalBullet}

UI_Skill_Tree :: struct{
    nodes : [dynamic]UI_Skill_Node,
    lines : [dynamic]UI_Skill_Line,
    type : UI_Skill_Tree_Type,
}

UI_Skill_Node :: struct{
    name : UI_Text,
    desc : UI_Text,
    used : UI_Text,
    pos : rl.Vector2,
    radius : f32,
    state : UI_Node_State,
    apply : proc(n : ^UI_Skill_Node),
    count : i32,
    max_count : i32,
    needed_count : i32,
    is_active : bool,
}

UI_Skill_Line :: struct{
    from_idx : i32,
    to_idx : i32,
}

//UI Cooldown
UI_Cooldown :: struct{
    rec : rl.Rectangle,
    value : f32,
    max : f32,
    icon : rl.Texture2D,
}

//UI_Label
UI_Label :: struct{
    text : UI_Text,
    rec : rl.Rectangle,
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
    rec : rl.Rectangle,
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
    rec : rl.Rectangle,
    slider : rl.Rectangle,
    state : Slider_state,
    color : rl.Color,
    n_color : rl.Color,
    a_color : rl.Color,
}
//Text
V_Alignment :: enum {
    Left, Center, Right
}

H_Alignment :: enum{
    Top, Center, Bottom
}

UI_Text :: struct{
    content : string,
    font_size : i32,
    text_color : rl.Color,
    valign : V_Alignment,
    halign : H_Alignment,
}
//Tooltip
UI_ToolTip :: struct {
    rec : rl.Rectangle,
    color : rl.Color,
    text : UI_Text,
    is_active : bool,
}
//Status
UI_Status_Bar :: struct{
    pos : rl.Vector2,
    complete_width : f32,
    complete_height : f32,
    slot_width : f32,
    slot_height : f32,
    seperation : f32,
    slots : [dynamic]UI_Status_Slot,
}

UI_Status_Slot :: struct{
    rec : rl.Rectangle,
    texture : rl.Color,
    text : string,
}
//Interact in game
UI_Interact :: struct{
    rec : rl.Rectangle,
    text : UI_Text,
    interactable : any,
}