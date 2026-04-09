package upgrade

create_dash_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_dash_upgrade("More Dash", "Decrease the cd of your ability by 5%", 0.95, .Multiplicative, .Attack_Speed, .Common)
    append(a, common)
}

create_dash_upgrade :: proc(name : string, desc : string,
    value : f32, type : Upgrade_Type, stat : Upgrade_Stat, rarity : Rarity) -> Upgrade{
    
    return{
        name = name,
        desc = desc,
        value = value,
        type = type,
        rarity = rarity,
        stat = stat,
        target = .Dash,
    }
}