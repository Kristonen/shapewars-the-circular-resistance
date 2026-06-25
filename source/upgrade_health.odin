package game

import rl "vendor:raylib"

create_health_upgrades :: proc(){
    common_m := create_upgrade("Better Nutrition", "Increase the life by 10.", 10.0, .Additive, .Common)
    common_m.apply = apply_max_health_upgrade
    common_c := create_upgrade("Medicine", "Heals you by 5.", 5, .Additive, .Common)
    common_c.apply = apply_current_health_upgrade
    rare := create_upgrade("Survival Lesson", "Increase the life by 10%", 1.1, .Multiplicative, .Rare)
    rare.apply = apply_max_health_upgrade
    legendary := create_upgrade("Holy Water", "Heals you by 100.", 100, .Additive, .Legendary)
    legendary.apply = apply_current_health_upgrade
    new_upgrades : []Upgrade = {common_m, common_c, rare, legendary}
    add_entity_to_game(new_upgrades[:], game.level.upgrade_pool[:])
}

apply_current_health_upgrade :: proc(u : Upgrade){
    stat := &game.player.health.heal_amount
    v := u.value.(f32)
    apply_upgrade(.Additive, stat, v)
}

apply_max_health_upgrade :: proc(u : Upgrade){
    stat := &game.player.health.max
    v := u.value.(f32)
    apply_upgrade(u.type, stat, v)
}