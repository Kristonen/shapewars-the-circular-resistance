package game

import rl "vendor:raylib"

create_dash_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_upgrade("More Dash", "Decrease the cd of your ability by 2%", 0.98, .Multiplicative, .Common)
    common.target = .Dash
    common.apply = apply_dash_cd_upgrade
    epic := create_upgrade("Dash Attack", "Dash now deals damage to every enemy, that u touch while dashing", true, .Toogle, .Epic)
    epic.target = .Dash
    epic.apply = apply_dash_attack_upgrade
    append(a, common)
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