package upgrade

create_health_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_health_upgrade("Better Nutrition", "Increase the life by 10.", 10, .Additive, .Common)
    rare := create_health_upgrade("Survival Lesson", "Increase the life by 10%", 1.1, .Multiplicative, .Rare)
    append(a, common)
    append(a, rare)
}

create_health_upgrade :: proc(name : string, desc : string, 
    value : f32, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    
    return {
        name = name,
        desc = desc,
        value = value,
        type = type,
        rarity = .Common,
        stat = .Health,
        target = .Player,
    }
}