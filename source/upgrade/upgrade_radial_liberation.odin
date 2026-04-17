package upgrade

create_rl_upgrades :: proc(a : ^[dynamic]Upgrade){
    epic := create_rl_upgrade("More Bullets", "Increase the amount of bullets by 2.", 2, .Additive, .Amount, .Epic)
    uncommon := create_rl_upgrade("Radical Damage", "Increase the damage of your ability by 5.", 5, .Additive, .Damage,.Uncommon)
    rare := create_rl_upgrade("Synthetic Power", "Decrease the cd by 5%", 0.95, .Multiplicative, .Attack_Speed, .Rare)
    legendary := create_rl_upgrade("Radial Vampire", "Bullets from the ability, have now lifesteal", true, .Toogle, .Lifesteal, .Legendary)
    legendary.max_used = 1
    legendary.toogle_target = .LifeStealAbility
    append(a, epic)
    append(a, uncommon)
    append(a, rare)
    append(a, legendary)
}

create_rl_upgrade :: proc(name : string, desc : string,
    value : Upgrade_Value, type : Upgrade_Type, stat : Upgrade_Stat, rarity : Rarity) -> Upgrade{
    
    return{
        name = name,
        desc = desc,
        value = value,
        type = type,
        rarity = rarity,
        stat = stat,
        target = .Radial_Liberation,
    }
}