package game

import rl "vendor:raylib"

create_dmg_upgrades :: proc(a : ^[dynamic]Upgrade){
    uncommon := create_dmg_upgrade("Circle improvement", "Increase the damage by 5.", 5, .Additive, .Uncommon)
    epic := create_dmg_upgrade("Circular Engineering", "Increase damage by 25%.", 1.25, .Multiplicative, .Epic)
    ls_epic := create_ls_upgrade("Bloodthirsty", "Increase the lifesteal by 0.01", 0.01, .Additive, .Epic)
    append(a, uncommon)
    append(a, epic)
    append(a, ls_epic)
}

create_dmg_upgrade :: proc(name : string, desc : string, value : f32, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    return{
        name = name,
        desc = desc,
        value = value,
        texture = rl.BLACK,
        rarity = rarity,
        target = .Player,
        type = type,
        apply = apply_dmg_upgrade,
    }
}

create_ls_upgrade :: proc(name : string, desc : string, value : f32, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    return{
        name = name,
        desc = desc,
        value = value,
        texture = rl.BLACK,
        rarity = rarity,
        target = .Player,
        type = type,
        apply = apply_lifesteal_upgrade,
    }
}

apply_dmg_upgrade :: proc(u : Upgrade){
    stat := &game.player.weapon.bullet.damage
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}

apply_lifesteal_upgrade :: proc(u : Upgrade){
    stat := &game.player.weapon.lifesteal
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}