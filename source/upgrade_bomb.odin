package game

import rl "vendor:raylib"

create_bomb_upgrades :: proc(){
    common := create_upgrade("TickTack", "Decrease the bomb timer by 10%", 0.9, .Multiplicative, .Common)
    uncommon := create_upgrade("Bigger Bomb", "Increase the radius of the bomb explosion by 15%", 1.15, .Multiplicative, .Uncommon)
    o_uncommon := create_upgrade("Deeper Wounds", "Increase the duration of the bleed status by 10%", 1.1, .Multiplicative, .Uncommon)
    rare := create_upgrade("More BOOM", "Increase the Damage of the bomb by 10.", 10, .Additive, .Rare)
    o_rare := create_upgrade("Stronger Bleed", "Increase the bleeding damage by 2.", 2, .Additive, .Rare)
    legendary := create_upgrade("Splitter-Bomb", "All enemies get bleed status.", true, .Toogle, .Legendary)

    common.target = .Bomb
    uncommon.target = .Bomb
    o_uncommon.target = .Bomb
    rare.target = .Bomb
    o_rare.target = .Bomb
    legendary.target = .Bomb

    o_uncommon.check_condition = check_if_bomb_can_splitter
    o_rare.check_condition = check_if_bomb_can_splitter

    common.apply = apply_bomb_timer_upgrade
    uncommon.apply = apply_bomb_radius_upgrade
    o_uncommon.apply = apply_bomb_bleed_duration_upgrade
    rare.apply = apply_bomb_dmg_upgrade
    o_rare.apply = apply_bomb_bleed_damage_upgrade
    legendary.apply = apply_bomb_splitter_upgrade

    legendary.max_used = 1
    new_upgrades : []Upgrade = {common, uncommon, o_uncommon, rare, o_rare, legendary}
    add_entity_to_game(new_upgrades[:], game.level.upgrade_pool[:])
}

check_if_bomb_can_splitter :: proc() -> bool{
    data := game.player.ability.data.(Bomb_Data)
    return data.can_splitter
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

apply_bomb_bleed_damage_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Bomb_Data)
    status := &data.bleed_status.type.(TickStatus)
    stat := &status.strength
    v := u.value.(f32)
    apply_upgrade(.Additive, stat, v)
}

apply_bomb_bleed_duration_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Bomb_Data)
    stat := &data.bleed_status.duration
    v := u.value.(f32)
    apply_upgrade(.Additive, stat, v)
}