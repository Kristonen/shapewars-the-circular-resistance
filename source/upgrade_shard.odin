package game

create_shard_upgrades :: proc(a : ^[dynamic]Upgrade){
    rare := create_shard_upgrade("Small Pocket Money", "Increase the multiplier by 0.1.", 0.1, .Additive, .Rare)
    legendary := create_shard_upgrade("GREED", "Increase the multiplier by 50%", 1.50, .Multiplicative, .Legendary)
    append(a, rare)
    append(a, legendary)
}

create_shard_upgrade :: proc(name : string, desc : string, value : Upgrade_Value, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    return {
        name = name,
        desc = desc,
        value = value,
        type = type,
        rarity = rarity,
        apply = apply_mul_shard_upgrade,
    }
}

apply_mul_shard_upgrade :: proc(u : Upgrade){
    stat := &game.player.loot_bag.mul
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}