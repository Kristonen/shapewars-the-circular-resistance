package game

import rl "vendor:raylib"

create_skill_node :: proc(name : string, desc : string, max_count : i32, pos : rl.Vector2) -> UI_Skill_Node{
    return {
        name = {
            content = name,
            font_size = 30,
            text_color = rl.WHITE,
            halign = .Center,
            valign = .Center,
        },
        desc = {
            content = desc,
            font_size = 25,
            text_color = rl.WHITE,
            halign = .Center,
            valign = .Center,
        },
        used = {
            font_size = 20,
            text_color = rl.WHITE,
            halign = .Center,
            valign = .Center,

        },
        pos = pos,
        radius = 20,
        max_count = max_count,
    }
}

apply_node_dmg :: proc(n : ^UI_Skill_Node, is_counting : bool = true){
    if is_counting{
        n.count += 1
    }
    stat := &game.player.weapon.bullet.damage
    stat^ += 5
}

apply_node_rl_cd :: proc(n : ^UI_Skill_Node, is_counting : bool = true){
    if is_counting{
        n.count += 1
    }
    a := &game.player.ability.(Radial_Liberation)
    stat := &a.ability_cd.cast_rate
    stat^ *= 0.96
}

apply_node_burn_status :: proc(n : ^UI_Skill_Node, is_counting : bool = true){
    if is_counting{
        n.count += 1
    }
    clear(&game.player.weapon.bullet.applied_status)
    status := create_fire_status(2, 0.5, 2)
    append(&game.player.weapon.bullet.applied_status, status)
}

apply_node_burn_dmg :: proc(n : ^UI_Skill_Node, is_counting : bool = true){
    if is_counting{
        n.count += 1
    }
    for &s in game.player.weapon.bullet.applied_status{
        if s.type != .Burn do continue
        s.strength += 2
    }
}

apply_node_poison_status :: proc(n : ^UI_Skill_Node, is_counting : bool = true){
    if is_counting{
        n.count += 1
    }
    clear(&game.player.weapon.bullet.applied_status)
    status := create_poison_status()
    append(&game.player.weapon.bullet.applied_status, status)
}