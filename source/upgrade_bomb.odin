package game

import rl "vendor:raylib"

create_bomb_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_upgrade("TickTack", "Decrease the bomb timer by 10%", 0.9, .Multiplicative, .Common)
    uncommon := create_upgrade("Bigger Bomb", "Increase the radius of the bomb explosion by 15%", 1.15, .Multiplicative, .Uncommon)
    rare := create_upgrade("More BOOM", "Increase the Damage of the bomb by 10.", 10, .Additive, .Rare)
    legendary := create_upgrade("Splitter-Bomb", "All enemies get bleed status.", true, .Toogle, .Legendary)

    common.target = .Bomb
    uncommon.target = .Bomb
    rare.target = .Bomb
    legendary.target = .Bomb

    common.apply = apply_bomb_timer_upgrade
    uncommon.apply = apply_bomb_radius_upgrade
    rare.apply = apply_bomb_dmg_upgrade
    legendary.apply = apply_bomb_splitter_upgrade

    legendary.max_used = 1

    append(a, common)
    append(a, uncommon)
    append(a, rare)
    append(a, legendary)
}

apply_bomb_radius_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Bomb_Data)
    stat := &data.explosion_radius
    v := u.value.(f32)
    apply_upgrade(.Multiplicative, stat, v)
}

apply_bomb_dmg_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Bomb_Data)
    stat := &data.damage
    v := u.value.(f32)
    apply_upgrade(.Additive, stat, v)
}

apply_bomb_timer_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Bomb_Data)
    stat := &data.timer
    v := u.value.(f32)
    apply_upgrade(.Multiplicative, stat, v)
    data.time_left = stat^
}

apply_bomb_splitter_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Bomb_Data)
    stat := &data.can_splitter
    v := u.value.(bool)
    apply_upgrade(stat, v)
}