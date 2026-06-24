package game

import "core:fmt"
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

apply_node_dmg :: proc(n : ^UI_Skill_Node, refund : bool = true){
    stat := &game.player.weapon.bullet.damage
    if refund{
        stat^ -= 5
    } else{
        stat^ += 5
    }
}

apply_node_rl_cd :: proc(n : ^UI_Skill_Node, refund : bool = true){
    stat := &game.player.ability.cooldown_timer.cast_rate
    if refund{
        stat^ *= 0.96
    } else{
        stat^ += (stat^ / 96 * 100)
    }
}

apply_node_burn_status :: proc(n : ^UI_Skill_Node, refund : bool = true){
    clear_bullet_status()
    if !refund{
        status := create_fire_status(2, 0.5, 2)
        game.player.weapon.bullet.applied_status[0] = status
    }
}

apply_node_burn_dmg :: proc(n : ^UI_Skill_Node, refund : bool = true){
    for &s in game.player.weapon.bullet.applied_status{
        if s.desc != .Burn do continue
        tick_status := &s.type.(TickStatus)
        tick_status.strength += 2
    }
}

apply_node_poison_status :: proc(n : ^UI_Skill_Node, refund : bool = true){
    clear_bullet_status()
    status := create_poison_status(2, 0.2, 2)
    game.player.weapon.bullet.applied_status[0] = status
}

check_if_node_can_be_refund :: proc(from_node : UI_Skill_Node, idx : i32, skilltree_type : string) -> bool{
    for l in game.skilltrees[skilltree_type].lines{
        if l.from_idx != idx do continue
        to_node := game.skilltrees[skilltree_type].nodes[l.to_idx]
        if to_node.count == 0 do return true
        if from_node.count == to_node.needed_count do return false
    }
    return true
}