package game

import rl "vendor:raylib"

create_bullet_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_bullet_upgrade("Faster projectile", "Increase the speed of your bullet by 25.", 25, .Additive, .Common)
    legendary := create_bullet_upgrade("Pierce Bullet", "Bullets will not destroy on hit.", true, .Toogle, .Legendary)
    epic := create_bullet_upgrade("Multishot", "Add one bullet to your primary shotting.", 1, .Additive, .Epic)
    common.apply = apply_speed_upgrade
    legendary.apply = apply_pierce_upgrade
    legendary.max_used = 1
    epic.apply = apply_amount_upgrade
    append(a, common)
    append(a, epic)
    append(a, legendary)
}

create_bullet_upgrade :: proc(name : string, desc : string, value : Upgrade_Value, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
    return {
        name = name,
        desc = desc,
        value = value,
        texture = rl.BLACK,
        rarity = rarity,
        type = type,
    }
}

apply_pierce_upgrade :: proc(u : Upgrade){
    stat := &game.player.weapon.bullet.can_pierce
    v := u.value.(bool)
    apply_toogle_upgrade(stat, v)
}

apply_amount_upgrade :: proc(u : Upgrade){
    stat := &game.player.weapon.amount
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}

apply_speed_upgrade :: proc(u : Upgrade){
    stat := &game.player.weapon.bullet.speed
    v := u.value.(f32)
    apply_normal_upgrade(u.type, stat, v)
}