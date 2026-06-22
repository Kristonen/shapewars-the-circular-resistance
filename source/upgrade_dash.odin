package game

import rl "vendor:raylib"

create_dash_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_upgrade("More Dash", "Decrease the cd of your ability by 2%", 0.98, .Multiplicative, .Common)
    uncommon := create_upgrade("Harder Dash", "Increase the damage of your dash by 10", 10, .Additive, .Uncommon)
    epic := create_upgrade("Dash Attack", "Dash now deals damage to every enemy, that u touch while dashing", true, .Toogle, .Epic)

    common.target = .Dash
    uncommon.target = .Dash
    epic.target = .Dash
    epic.max_used = 1

    common.apply = apply_dash_cd_upgrade
    uncommon.apply = apply_dash_damage_upgrade
    epic.apply = apply_dash_attack_upgrade

    uncommon.check_condition = check_if_dash_can_attack

    append(a, common)
append(a, uncommon)
    append(a, epic)
}

apply_dash_cd_upgrade :: proc(u : Upgrade){
    stat := &game.player.ability.cooldown_timer.cast_rate
    v := u.value.(f32)
    apply_upgrade(u.type, stat, v)
}

apply_dash_attack_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Dash_Data)
    stat := &data.can_attack
    v := u.value.(bool)
    apply_upgrade(stat, v)
}

check_if_dash_can_attack :: proc() -> bool{
    data := game.player.ability.data.(Dash_Data)
    return data.can_attack
}

apply_dash_damage_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Dash_Data)
    stat := &data.damage
    v := u.value.(f32)
    apply_upgrade(.Additive, stat, v)
}