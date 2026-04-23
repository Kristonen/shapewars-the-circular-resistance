package game

create_movement_speed_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_movement_speed_upgrade("Light feet", "Increase the movement speed by 5%.", 1.05, .Multiplicative, .Common)
    append(a, common)
}

create_movement_speed_upgrade :: proc(name : string, desc : string, value : f32, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    return {
        name = name,
        desc = desc,
        value = value,
        type = type,
        rarity = rarity,
        target = .Player,
        apply = apply_movespeed_upgrade,
    }
}

apply_movespeed_upgrade :: proc(u : Upgrade){
    stat := &game.player.speed
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}