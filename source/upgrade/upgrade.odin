package upgrade

import "core:math/rand"
import rl "vendor:raylib"

Upgrade_Target :: enum { Player, Radial_Liberation, Dash }
Upgrade_Stat :: enum { Move_Speed, Attack_Speed, Damage, Health, Amount, Lifesteal }
Upgrade_Type :: enum{ Additive, Multiplicative, Subtrative, Division, Toogle }
Upgrade_Toogle_Target :: enum{Pierce, LifeStealAbility }
Rarity :: enum{ Common, Uncommon, Rare, Epic, Legendary }

UpgradeSlot_State :: enum{
    None, Focused, Selected
}

Upgrade_Value :: union{
    f32, bool
}

Upgrade :: struct{
    name : string,
    desc : string,
    value : Upgrade_Value,
    texture : rl.Color,
    rarity : Rarity,
    target : Upgrade_Target,
    stat : Upgrade_Stat,
    type : Upgrade_Type,
    toogle_target : Upgrade_Toogle_Target,
    max_used : i32,
    count_used : i32,
}

UI_Upgrade_Slot :: struct{
    rect : rl.Rectangle,
    upgrade : ^Upgrade,
    state : UpgradeSlot_State,
    color : rl.Color,
}

UI_Upgrade_Menu :: struct{
    width : f32,
    height : f32,
    upgrades : [3]UI_Upgrade_Slot,
    shader : Upgrade_Shader,
    is_active : bool,
}

Upgrade_Shader :: struct{
    bloom : rl.Shader,
    u_time_loc : i32,
    color_loc : i32,
    test : f32,
    timer : f32,
}

create_upgrade_menu :: proc(m : ^UI_Upgrade_Menu, u : [dynamic]Upgrade, a_target : Upgrade_Target){
    m.width = f32(rl.GetScreenWidth())
    m.height = f32(rl.GetScreenHeight())
    m.is_active = !rl.IsMouseButtonDown(.LEFT)
    used_idx : [3]i32
    used_idx[0] = -1
    used_idx[1] = -1
    used_idx[2] = -1
    for i in 0..<3{
        upgrade, idx := get_random_upgrade_by_rarity(u, used_idx)
        used_idx[i] = idx
        m.upgrades[i] = create_upgrade_slot(upgrade, f32(i))
    }
}

is_upgrade_already_used :: proc(n : i32, idx_array : [3]i32) -> bool{
    for idx in idx_array{
        if n == idx{
            return true
        }
    }
    return false
}
//TODO Improve that the rarity only roll once, instead of every single check
get_random_upgrade_by_rarity :: proc(u : [dynamic]Upgrade, used_idx : [3]i32) -> (^Upgrade, i32){
    upgrade : ^Upgrade
    rand_idx : i32
    rarity := get_random_rarity()
    for true{
        rand_idx = rand.int32_range(0, i32(len(u)))
        upgrade = &u[rand_idx]
        if upgrade.max_used > 0 && upgrade.count_used >= upgrade.max_used do continue
        if rarity != upgrade.rarity || is_upgrade_already_used(rand_idx, used_idx) do continue
        break
    }
    return upgrade, rand_idx
}

get_random_rarity :: proc() -> Rarity{
    rand := rand.float32()
    if rand <= 0.02{
        return .Legendary
    } else if rand <= 0.10{
        return .Epic
    } else if rand <= 0.25{
        return .Rare
    } else if rand <= 0.50{
        return .Uncommon
    } else {
        return .Common
    }
}

create_upgrades :: proc(a : ^[dynamic]Upgrade){
    create_dmg_upgrades(a)
    create_movement_speed_upgrades(a)
    create_as_upgrades(a)
    create_health_upgrades(a)
    create_rl_upgrades(a)
    create_dash_upgrades(a)
}

create_upgrade_slot :: proc(u : ^Upgrade, mul : f32) -> UI_Upgrade_Slot{
    rect : rl.Rectangle
    rect.width = 500
    rect.height = 800
    rect.x = 150 + (rect.width * mul) + (50 * mul)
    rect.y = f32(rl.GetScreenHeight()) / 2 - rect.height / 2
    return {
        rect = rect,
        upgrade = u,
        color = get_upgrade_color(u.rarity),
    }
}

get_upgrade_color :: proc(r : Rarity) -> rl.Color{
    switch r{
        case .Common: return rl.SKYBLUE
        case .Uncommon: return rl.DARKBLUE
        case .Rare: return rl.GREEN
        case .Epic: return rl.VIOLET
        case .Legendary: return rl.ORANGE
    }
    return rl.WHITE
}