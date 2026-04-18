package upgrade

create_health_upgrades :: proc(a : ^[dynamic]Upgrade){
    common_m := create_max_health_upgrade("Better Nutrition", "Increase the life by 10.", 10.0, .Additive, .Common)
    common_c := create_current_health_upgrade("Medicine", "Heals you by 5.", 5, .Additive, .Common)
    rare := create_max_health_upgrade("Survival Lesson", "Increase the life by 10%", 1.1, .Multiplicative, .Rare)
    legendary := create_current_health_upgrade("Holy Water", "Heals you by 100.", 100, .Additive, .Legendary)
    append(a, common_m)
    append(a, common_c)
    append(a, rare)
    append(a, legendary)
}

create_max_health_upgrade :: proc(name : string, desc : string, 
    value : f32, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    
    return {
        name = name,
        desc = desc,
        value = value,
        type = type,
        rarity = rarity,
        stat = .MaxHealth,
        target = .Player,
    }
}

create_current_health_upgrade :: proc(name : string, desc : string, 
    value : f32, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    
    return {
        name = name,
        desc = desc,
        value = value,
        type = type,
        rarity = rarity,
        stat = .CurrentHealth,
        target = .Player,
    }
}