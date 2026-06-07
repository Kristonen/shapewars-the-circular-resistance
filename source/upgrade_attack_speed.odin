package game

import rl "vendor:raylib"

create_as_upgrades :: proc(a : ^[dynamic]Upgrade){
    uncommon := create_upgrade("MORE", "Increase the attack speed by 5%", 0.95, .Multiplicative, .Uncommon)
    uncommon.apply = apply_attack_speed_upgrade
    rare := create_upgrade("AND MORE", "Increase the attack speed by 10%", 0.90, .Multiplicative, .Rare)
    rare.apply = apply_attack_speed_upgrade
    append(a, uncommon)
    append(a, rare)
}

apply_attack_speed_upgrade :: proc(u : Upgrade){
    stat := &game.player.weapon.fire_rate
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}