package ui

import rl "vendor:raylib"
import "core:fmt"

create_test_skilltree :: proc(st : ^UI_Skill_Tree){
    mid := rl.Vector2{f32(rl.GetScreenWidth()/2), f32(rl.GetScreenHeight()/2)}
    node_one := UI_Skill_Node{
        name = {
            content = "Test",
            font_size = 30,
            text_color = rl.WHITE,
            halign = .Center,
            valign = .Center,
        },
        desc = {
            content = "Add something",
            font_size = 25,
            text_color = rl.WHITE,
            halign = .Top,
            valign = .Center,
        },
        used = {
            font_size = 20,
            text_color = rl.WHITE,
            halign = .Center,
            valign = .Center,
        },
        max_count = 5,
        pos = {mid.x + 200, mid.y + 200},
        radius = 20,
        apply = apply_skill_node,
        is_active = true
    }
    node_two := node_one
    node_two.pos.x += 200
    node_two.needed_count = 2
    node_two.name.content = "Krasser Skill"
    node_two.is_active = false
    node_three := node_two
    node_three.name.content = "Ultimatives Super Teil"
    node_three.pos.x += 150
    node_three.pos.y -= 150
    node_three.needed_count = 4
    append(&st.nodes, node_one)
    append(&st.nodes, node_two)
    append(&st.nodes, node_three)
    line := UI_Skill_Line{
        to_idx = 1,
        from_idx = 0,
    }
    line_two := UI_Skill_Line{
        to_idx = 2,
        from_idx = 1,
    }
    append(&st.lines, line)
    append(&st.lines, line_two)
}

apply_skill_node :: proc(n : ^UI_Skill_Node){
    n.count += 1
}