package game

import rl "vendor:raylib"

create_shard_upgrades :: proc(a : ^[dynamic]Upgrade){
    rare := create_upgrade("Small Pocket Money", "Increase the multiplier by 0.1.", 0.1, .Additive, .Rare)
    rare.apply = apply_mul_shard_upgrade
    epic := create_upgrade("Longer Arm", "Increase the radius to gather loot by 15%", 1.15, .Multiplicative, .Epic)
    epic.apply = apply_increase_radius_upgrade
    legendary := create_upgrade("GREED", "Increase the multiplier by 50%", 1.50, .Multiplicative, .Legendary)
    legendary.apply = apply_mul_shard_upgrade

    append(a, rare)
    append(a, legendary)
    append(a, epic)
}

apply_mul_shard_upgrade :: proc(u : Upgrade){
    stat := &game.player.loot_bag.mul
    v := u.value.(f32)
    apply_upgrade(u.type, stat, v)
}

apply_increase_radius_upgrade :: proc(u : Upgrade){
    stat := &game.player.loot_detector.radius
    v := u.value.(f32)
    apply_upgrade(u.type, stat, v)
}