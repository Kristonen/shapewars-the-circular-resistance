package game

import rl "vendor:raylib"
import "core:fmt"
import "ui"

//UI Skill Tree
UI_Node_State :: enum{None, Focussed, Pressed}
Skilltree_Type :: enum {NormalBullet, BetterBullet}

UI_Skill_Tree :: struct{
    nodes : [dynamic]UI_Skill_Node,
    lines : [dynamic]UI_Skill_Line,
    type : Skilltree_Type,
    // texture : rl.Texture `json:"-"`,
    unlocked : bool,
}

UI_Skill_Node :: struct{
    name : ui.UI_Text,
    desc : ui.UI_Text,
    used : ui.UI_Text,
    pos : rl.Vector2,
    radius : f32,
    state : UI_Node_State,
    apply : proc(n : ^UI_Skill_Node) `json:"-"`,
    count : i32,
    max_count : i32,
    needed_count : i32,
    is_active : bool,
}

UI_Skill_Line :: struct{
    from_idx : i32,
    to_idx : i32,
}

create_skill_tree :: proc(type : Skilltree_Type, a : ^map[string]UI_Skill_Tree){
    switch type{
        case .NormalBullet:
            create_normal_bullet_skilltree(type, a)
        case .BetterBullet:
    }
    
}

create_normal_bullet_skilltree :: proc(type : Skilltree_Type, a : ^map[string]UI_Skill_Tree){
    st : UI_Skill_Tree
    if type == .NormalBullet{
        st.unlocked = true    
    } else{
        st.unlocked = false
    }
    st.type = type
    
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
        apply = apply_dmg_node,
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
    node_four := node_one
    node_four.pos.y -= 300
    node_four.pos.x += 50
    node_four.needed_count = 3
    node_four.is_active = false
    append(&st.nodes, node_one)
    append(&st.nodes, node_two)
    append(&st.nodes, node_three)
    append(&st.nodes, node_four)
    line := UI_Skill_Line{
        to_idx = 1,
        from_idx = 0,
    }
    line_two := UI_Skill_Line{
        to_idx = 2,
        from_idx = 1,
    }
    line_three := UI_Skill_Line{
        to_idx = 3,
        from_idx = 0,
    }
    append(&st.lines, line)
    append(&st.lines, line_two)
    append(&st.lines, line_three)
    text := fmt.tprintf("%v", type)
    a[text] = st
}

// apply_dmg_skill_node :: proc(n : ^UI_Skill_Node){
//     n.count += 1
// }