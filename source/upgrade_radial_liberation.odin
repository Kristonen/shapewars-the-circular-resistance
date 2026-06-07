package game

import rl "vendor:raylib"

create_rl_upgrades :: proc(a : ^[dynamic]Upgrade){
    epic := create_upgrade("More Bullets", "Increase the amount of bullets by 2.", 2, .Additive, .Epic)
    uncommon := create_upgrade("Radical Damage", "Increase the damage of your ability by 5.", 5, .Additive, .Uncommon)
    rare := create_upgrade("Synthetic Power", "Decrease the cd by 5%", 0.95, .Multiplicative, .Rare)
    legendary := create_upgrade("Radial Vampire", "Bullets from the ability, have now lifesteal", true, .Toogle, .Legendary)

    epic.target = .Radial_Liberation
    
    epic.apply = apply_rl_amount_upgrade
    uncommon.apply = apply_rl_dmg_upgrade
    rare.apply = apply_rl_cd_upgrade
    legendary.apply = apply_rl_lifesteal_upgrade
    legendary.max_used = 1

    append(a, epic)
    append(a, uncommon)
    append(a, rare)
    append(a, legendary)
}
apply_rl_cd_upgrade :: proc(u : Upgrade){
    stat := &get_ability_cd().cast_rate
    // stat := &game.player.ability_cd.cast_rate
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}

apply_rl_dmg_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Radial_Liberation_Data)
    stat := &data.dmg
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}

apply_rl_amount_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Radial_Liberation_Data)
    stat := &data.amount
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}

apply_rl_lifesteal_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Radial_Liberation_Data)
    stat := &data.can_lifesteal
    v := u.value.(bool)
    apply_toogle_upgrade(stat, v)
}