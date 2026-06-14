package game

import rl "vendor:raylib"

create_dmg_upgrades :: proc(a : ^[dynamic]Upgrade){
    uncommon := create_upgrade("Circle improvement", "Increase the damage by 5.", 5, .Additive, .Uncommon)
    uncommon.apply = apply_dmg_upgrade
    epic := create_upgrade("Circular Engineering", "Increase damage by 25%.", 1.25, .Multiplicative, .Epic)
    epic.apply = apply_dmg_upgrade
    ls_epic := create_upgrade("Bloodthirsty", "Increase the lifesteal by 0.01", 0.01, .Additive, .Epic)
    ls_epic.apply = apply_lifesteal_upgrade
    append(a, uncommon)
    append(a, epic)
    append(a, ls_epic)
}

apply_dmg_upgrade :: proc(u : Upgrade){
    stat := &game.player.weapon.bullet.damage
    v := u.value.(f32)
    apply_upgrade(u.type, stat, v)
}

apply_lifesteal_upgrade :: proc(u : Upgrade){
    stat := &game.player.weapon.lifesteal
    v := u.value.(f32)
    apply_upgrade(u.type, stat, v)
}