package ui

import "core:strings"
import rl "vendor:raylib"

UI_Label :: struct{
    text : string,
    pos : rl.Vector2,
    width : f32,
    height : f32,
    font_size : i32,
    text_color : rl.Color,
    color : rl.Color,
}

create_label :: proc(text : string, pos : rl.Vector2, size : rl.Vector2) -> UI_Label{
    return {
        text = text,
        pos = pos,
        width = size.x,
        height = size.y, 
        font_size = 50,
        text_color = rl.WHITE,
        color = rl.GRAY,
    }
}

update_label :: proc(l : ^UI_Label){

}

draw_label :: proc(l : UI_Label){
    rec := rl.Rectangle{
        x = l.pos.x,
        y = l.pos.y,
        width = l.width,
        height = l.height,
    }
    
    rl.DrawRectangleV(l.pos, {l.width, l.height}, l.color)
    rl.DrawRectangleLinesEx(rec, 5, rl.BLACK)
    text := strings.clone_to_cstring(l.text)
    text_width := rl.MeasureText(text, l.font_size)
    text_height := l.font_size
    text_x := i32(l.pos.x) + (i32(l.width) - text_width) / 2
    text_y := i32(l.pos.y) + (i32(l.height) - text_height) / 2
    rl.DrawText(text, i32(text_x), i32(text_y), 50, l.text_color)
    delete_cstring(text)
}