package game

import rl "vendor:raylib"

create_dash_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_dash_upgrade("More Dash", "Decrease the cd of your ability by 5%", 0.95, .Multiplicative, .Common)
    append(a, common)
}

create_dash_upgrade :: proc(name : string, desc : string,
    value : f32, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
        
    return{
        name = {
            content = name,
            halign = .Center,
            valign = .Center,
            font_size = 30,
            text_color = rl.WHITE,
        },
        desc = {
            content = desc,
            halign = .Center,
            valign = .Center,
            font_size = 30,
            text_color = rl.WHITE
        },
        value = value,
        type = type,
        rarity = rarity,
        target = .Dash,
    }
}