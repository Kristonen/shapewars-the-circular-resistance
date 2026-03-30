package ability

import rl "vendor:raylib"

Ability :: union{
    Radial_Liberation,
}

Ability_Cooldown :: struct{
    cooldown : f32,
    timer : f32,
}

update_casting :: proc(a : ^Ability) -> bool{
    if rl.IsKeyPressed(.SPACE) && check_if_ability_not_on_cd(a^){
        set_ability_cooldown(a)
        return true
    }
    return false
}

check_if_ability_not_on_cd :: proc(a : Ability) -> bool{
    switch ability in a{
        case Radial_Liberation: return ability.cooldown.timer <= 0
    }
    return false
}

set_ability_cooldown :: proc(a : ^Ability){
    switch &ability in a{
        case Radial_Liberation: ability.cooldown.timer = ability.cooldown.cooldown
    }
}

update_ability :: proc(a : ^Ability, dt : f32){
    switch &ability in a{
        case Radial_Liberation:update_cooldown(&ability.cooldown, dt)
    }
}

update_cooldown :: proc(cd : ^Ability_Cooldown, dt : f32){
    if cd.timer > 0{
        cd.timer -= dt
    }
}

get_cooldown :: proc(a : Ability) -> Ability_Cooldown{
    switch ability in a{
        case Radial_Liberation: return ability.cooldown
    }
    return {}
}