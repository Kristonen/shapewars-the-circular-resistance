package game

create_dash_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_dash_upgrade("More Dash", "Decrease the cd of your ability by 5%", 0.95, .Multiplicative, .Common)
    append(a, common)
}

create_dash_upgrade :: proc(name : string, desc : string,
    value : f32, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    
    return{
        name = name,
        desc = desc,
        value = value,
        type = type,
        rarity = rarity,
        target = .Dash,
    }
}