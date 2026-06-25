package game

import rl "vendor:raylib"

create_as_upgrades :: proc(){
    uncommon := create_upgrade("MORE", "Increase the attack speed by 5%", 0.95, .Multiplicative, .Uncommon)
    uncommon.apply = apply_attack_speed_upgrade
    rare := create_upgrade("AND MORE", "Increase the attack speed by 10%", 0.90, .Multiplicative, .Rare)
    rare.apply = apply_attack_speed_upgrade
    new_upgrades : []Upgrade = {uncommon, rare}
    add_entity_to_game(new_upgrades[:], game.level.upgrade_pool[:])
}

apply_attack_speed_upgrade :: proc(u : Upgrade){
    stat := &game.player.weapon.fire_rate
    v := u.value.(f32)
    apply_upgrade(u.type, stat, v)
}