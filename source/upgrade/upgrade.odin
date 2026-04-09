package upgrade

import "core:math/rand"
import rl "vendor:raylib"

Upgrade_Target :: enum { Player, Radial_Liberation, Dash }
Upgrade_Stat :: enum { Move_Speed, Attack_Speed, Damage, Health, Amount }
Upgrade_Type :: enum{ Additive, Multiplicative, Subtrative, Division }
Rarity :: enum{ Common, Uncommon, Rare, Epic, Legendary }

Upgrade_State :: enum{
    None, Focused, Selected
}

Upgrade :: struct{
    name : string,
    desc : string,
    value : f32,
    texture : rl.Color,
    rarity : Rarity,
    target : Upgrade_Target,
    stat : Upgrade_Stat,
    type : Upgrade_Type,
}

UI_Upgrade_Slot :: struct{
    rect : rl.Rectangle,
    upgrade : Upgrade,
    state : Upgrade_State,
    color : rl.Color,
}

UI_Upgrade_Menu :: struct{
    width : f32,
    height : f32,
    upgrades : [3]UI_Upgrade_Slot,
    shader : Upgrade_Shader,
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
    used_idx : [3]i32
    used_idx[0] = -1
    used_idx[1] = -1
    used_idx[2] = -1
    // m.upgrades = create_test_upgrades()
    for i in 0..<3{
        upgrade, idx := get_random_upgrade_by_rarity(u, used_idx)
        used_idx[i] = idx
        m.upgrades[i] = create_upgrade_slot(upgrade, f32(i))
    }

    shader := rl.LoadShader(nil, "assets/test.frag")
    u_time_loc := rl.GetShaderLocation(shader, "u_time")
    color_loc := rl.GetShaderLocation(shader, "color")

    m.shader.bloom = shader
    m.shader.u_time_loc = u_time_loc
    m.shader.color_loc = color_loc
    m.shader.timer = 0.5
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
get_random_upgrade_by_rarity :: proc(u : [dynamic]Upgrade, used_idx : [3]i32) -> (Upgrade, i32){
    upgrade : Upgrade
    rand_idx : i32
    for true{
        rarity := get_random_rarity()
        rand_idx = rand.int32_range(0, i32(len(u)))
        upgrade = u[rand_idx]
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

create_upgrade_slot :: proc(u : Upgrade, mul : f32) -> UI_Upgrade_Slot{
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
        case .Epic: return rl.PURPLE
        case .Legendary: return rl.ORANGE
    }
    return rl.WHITE
}

create_test_upgrades :: proc() -> [3]UI_Upgrade_Slot{
    attack := Upgrade{
        name = "More Ouch",
        desc = "Increase the damage by 5",
        value = 5,
        texture = rl.BLUE,
        rarity = .Uncommon,
        type = .Additive,
        stat = .Damage,
        target = .Player,
    }
    attack_speed := Upgrade{
        name = "Faster pew",
        desc = "Increase the attack speed by 5%",
        value = 0.05,
        texture = rl.ORANGE,
        rarity = .Rare,
        type = .Additive,
        stat = .Attack_Speed,
        target = .Player,
    }
    health := Upgrade{
        name = "More life",
        desc = "Increase the health by 10",
        value = 10,
        texture = rl.VIOLET,
        rarity = .Common,
        type = .Additive,
        stat = .Health,
        target = .Player,
    }
    rect : rl.Rectangle
    rect.width = 500
    rect.height = 800
    rect.x = 170
    rect.y = f32(rl.GetScreenHeight()) / 2 - rect.height / 2
    ui_attack := UI_Upgrade_Slot{
        rect = rect,
        upgrade = attack,
        color = {130, 130, 130, 150},
    }
    rect.x += rect.width + 50
    ui_as := UI_Upgrade_Slot{
        rect = rect,
        upgrade = attack_speed,
        color = {130, 130, 130, 150},
    }
    rect.x += rect.width + 50
    ui_health := UI_Upgrade_Slot{
        rect = rect,
        upgrade = health,
        color = {130, 130, 130, 150},
    }
    return {ui_attack, ui_as, ui_health}
}