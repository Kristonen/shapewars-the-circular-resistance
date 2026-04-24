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
        is_active = true
    }
    node_two := node_one
    node_two.pos.x += 200
    node_two.is_active = false
    node_three := node_two
    node_three.pos.x += 150
    node_three.pos.y -= 150
    append(&st.nodes, node_one)
    append(&st.nodes, node_two)
    append(&st.nodes, node_three)
    line := UI_Skill_Line{
        to = node_two,
        from = node_one,
    }
    line_two := UI_Skill_Line{
        to = node_three,
        from = node_two,
    }
    append(&st.lines, line)
    append(&st.lines, line_two)
}