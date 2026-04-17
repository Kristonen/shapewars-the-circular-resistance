package upgrade

import rl "vendor:raylib"

create_dmg_upgrades :: proc(a : ^[dynamic]Upgrade){
    uncommon := create_dmg_upgrade("Circle improvement", "Increase the damage by 5.", 5, .Additive, .Uncommon)
    epic := create_dmg_upgrade("Circular Engineering", "Increase damage by 25%.", 1.25, .Multiplicative, .Epic)
    ls_epic := create_ls_upgrade("Bloodthirsty", "Increase the lifesteal by 0.1", 0.1, .Additive, .Common)
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
        stat = .Damage,
        type = type,
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
        stat = .Lifesteal,
        type = type,
    }
}