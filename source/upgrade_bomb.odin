package game

import rl "vendor:raylib"

create_bomb_upgrades :: proc(a : ^[dynamic]Upgrade){
    uncommon := create_upgrade("Bigger Bomb", "Increase the radius of the bomb explosion by 15%", 1.15, .Multiplicative, .Uncommon)

    uncommon.target = .Bomb

    uncommon.apply = apply_bomb_radius_upgrade
    append(a, uncommon)
}

apply_bomb_radius_upgrade :: proc(u : Upgrade){
    data := &game.player.ability.data.(Bomb_Data)
    stat := &data.explosion_radius
    v := u.value.(f32)
    apply_upgrade(.Multiplicative, stat, v)
}