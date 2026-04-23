package game

import rl "vendor:raylib"

create_as_upgrades :: proc(a : ^[dynamic]Upgrade){
    uncommon := create_as_upgrade("MORE", "Increase the attack speed by 5%", 0.95, .Multiplicative, .Uncommon)
    rare := create_as_upgrade("AND MORE", "Increase the attack speed by 10%", 0.90, .Multiplicative, .Rare)
    append(a, uncommon)
    append(a, rare)
}

create_as_upgrade :: proc(name : string, desc : string, value : f32, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
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
        target = .Player,
        apply = apply_attack_speed_upgrade,
    }
}

apply_attack_speed_upgrade :: proc(u : Upgrade){
    stat := &game.player.weapon.fire_rate
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}