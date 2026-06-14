package game

import rl "vendor:raylib"

create_movement_speed_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_upgrade("Light feet", "Increase the movement speed by 5%.", 1.05, .Multiplicative, .Common)
    common.apply = apply_movespeed_upgrade
    append(a, common)
}

apply_movespeed_upgrade :: proc(u : Upgrade){
    stat := &game.player.speed
    v := u.value.(f32)
    apply_upgrade(u.type, stat, v)
}