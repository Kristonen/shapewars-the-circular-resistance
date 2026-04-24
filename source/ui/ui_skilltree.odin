package ui

import rl "vendor:raylib"
import "core:fmt"

create_test_skilltree :: proc(st : ^UI_Skill_Tree){
    mid := rl.Vector2{f32(rl.GetScreenWidth()/2), f32(rl.GetScreenHeight()/2)}
    node_one := UI_Skill_Node{
        name = {
            content = "Test",
            font_size = 10,
            text_color = rl.WHITE,
            halign = .Top,
            valign = .Left,
        },
        desc = {
            content = "Add something",
            font_size = 5,
            text_color = rl.WHITE,
            halign = .Top,
            valign = .Left,
        },
        pos = {mid.x + 200, mid.y + 500},
        radius = 20,
        apply = proc(){fmt.println("Test")},
    }
    node_two := node_one
    node_two.pos.x += 200
    append(&st.nodes, node_one)
    append(&st.nodes, node_two)
    line := UI_Skill_Line{
        to = node_two,
        from = node_one,
    }
    append(&st.lines, line)
}