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
    apply : proc(n : ^UI_Skill_Node, is_counting : bool = true) `json:"-"`,
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

    n_one := create_skill_node("More Damage", "Increase your start damage by 5.", 6, {mid.x + 200, mid.y + 200})
    n_one.is_active = true
    n_one.apply = apply_node_dmg

    n_two := create_skill_node("Fire Bullets", "Add the burn buff to your bullet.", 1, {n_one.pos.x + 200, n_one.pos.y})
    n_two.needed_count = 4
    n_two.apply = apply_node_burn_status

    n_three := create_skill_node("Stronger Burn", "Increase the burn damage by 2.", 4, {n_two.pos.x + 150, n_two.pos.y - 150})
    n_three.needed_count = 1
    n_three.apply = apply_node_burn_dmg

    n_four := create_skill_node("Poison Bullets", "Add the poison buff to your bullet.", 1, {n_one.pos.x + 50, n_one.pos.y - 300})
    n_four.needed_count = 4
    n_four.apply = apply_node_poison_status

    append(&st.nodes, n_one)
    append(&st.nodes, n_two)
    append(&st.nodes, n_three)
    append(&st.nodes, n_four)

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