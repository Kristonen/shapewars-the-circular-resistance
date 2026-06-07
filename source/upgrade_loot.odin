package game

import rl "vendor:raylib"

create_shard_upgrades :: proc(a : ^[dynamic]Upgrade){
    rare := create_shard_upgrade("Small Pocket Money", "Increase the multiplier by 0.1.", 0.1, .Additive, .Rare)
    epic := create_detection_upgrade("Longer Arm", "Increase the radius to gather loot by 15%", 1.15, .Multiplicative, .Epic)
    legendary := create_shard_upgrade("GREED", "Increase the multiplier by 50%", 1.50, .Multiplicative, .Legendary)

    append(a, rare)
    append(a, legendary)
    append(a, epic)
}

create_shard_upgrade :: proc(name : string, desc : string, value : Upgrade_Value, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    return {
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
        apply = apply_mul_shard_upgrade,
    }
}

create_detection_upgrade :: proc(name : string, desc : string, value : Upgrade_Value, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    return {
        name ={
            content = name,
            halign = .Center,
            valign = .Center,
            font_size = 30,
            text_color = rl.WHITE,
        },
        desc ={
            content = desc,
            halign = .Center,
            valign = .Center,
            font_size = 30,
            text_color = rl.WHITE,
        },
        value = value,
        rarity = rarity,
        type = type,
        apply = apply_increase_radius_upgrade
    }
}

apply_mul_shard_upgrade :: proc(u : Upgrade){
    stat := &game.player.loot_bag.mul
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}

apply_increase_radius_upgrade :: proc(u : Upgrade){
    stat := &game.player.loot_detector.radius
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}