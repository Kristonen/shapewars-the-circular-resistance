package game

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
        target = .Player,
        apply = apply_max_health_upgrade,
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
        target = .Player,
        apply = apply_current_health_upgrade,
    }
}

apply_current_health_upgrade :: proc(g : ^Game_State, u : Upgrade){
    stat := &g.player.health.heal_amount
    v := u.value.(f32)
    apply_normal_upgrade(.Additive, stat, v)
}

apply_max_health_upgrade :: proc(g : ^Game_State, u : Upgrade){
    stat := &g.player.health.max
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}