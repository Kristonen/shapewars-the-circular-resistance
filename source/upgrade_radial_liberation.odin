package game

import "core:fmt"
create_rl_upgrades :: proc(a : ^[dynamic]Upgrade){
    epic := create_rl_upgrade("More Bullets", "Increase the amount of bullets by 2.", 2, .Additive, .Epic)
    uncommon := create_rl_upgrade("Radical Damage", "Increase the damage of your ability by 5.", 5, .Additive, .Uncommon)
    rare := create_rl_upgrade("Synthetic Power", "Decrease the cd by 5%", 0.95, .Multiplicative, .Rare)
    legendary := create_rl_upgrade("Radial Vampire", "Bullets from the ability, have now lifesteal", true, .Toogle, .Legendary)
    
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

create_rl_upgrade :: proc(name : string, desc : string,
    value : Upgrade_Value, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    
    return{
        name = name,
        desc = desc,
        value = value,
        type = type,
        rarity = rarity,
        target = .Radial_Liberation,
    }
}

apply_rl_cd_upgrade :: proc(u : Upgrade){
    stat := &game.player.ability_cd.cast_rate
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}

apply_rl_dmg_upgrade :: proc(u : Upgrade){
    ability := &game.player.ability.(Radial_Liberation)
    stat := &ability.damage
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}

apply_rl_amount_upgrade :: proc(u : Upgrade){
    ability := &game.player.ability.(Radial_Liberation)
    stat := &ability.count
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}

apply_rl_lifesteal_upgrade :: proc(u : Upgrade){
    ability := &game.player.ability.(Radial_Liberation)
    stat := &ability.can_lifesteal
    v := u.value.(bool)
    apply_toogle_upgrade(stat, v)
}