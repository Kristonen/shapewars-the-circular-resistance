package ui

import rl "vendor:raylib"

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
    width : f32,
    height : f32,
    pos : rl.Vector2,
    texture : rl.Color,
}

create_ui_status_bar :: proc(pos : rl.Vector2) -> UI_Status_Bar{
    return{
        pos = pos
    }
    // status_bar.pos = pos
    // width : f32 = 50
    // height : f32 = 50
    // for i in 0..<len(textures){
    //     t := textures[i]
    //     slot := create_status_slot(t)
    //     x := pos.x + width * f32(i)
    //     y := pos.y + height * f32(i)
    //     slot.pos = {x, y}
    //     slot.width = width
    //     slot.height = height
    //     status_bar
    // }
}

create_status_slot :: proc(pos : rl.Vector2, width : f32, height : f32, t : rl.Color) -> UI_Status_Slot{
    return {
        pos = pos,
        width = width,
        height = height,
        texture = t,
    }
}