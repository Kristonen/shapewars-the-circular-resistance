package game

import rl "vendor:raylib"

create_dash_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_upgrade("More Dash", "Decrease the cd of your ability by 2%", 0.98, .Multiplicative, .Common)
    common.target = .Dash
    common.apply = apply_dash_cd_upgrade
    append(a, common)
}

apply_dash_cd_upgrade :: proc(u : Upgrade){
    stat := &game.player.ability.cd.cast_rate
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}