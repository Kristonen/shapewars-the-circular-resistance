package game

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"
import "ui"

Apply_Upgrade :: #type proc(u : Upgrade)
Check_Upgrade_Condition :: #type proc() -> bool

Upgrade_Type :: enum{ Additive, Multiplicative, Subtrative, Division, Toogle }
Rarity :: enum{ Common, Uncommon, Rare, Epic, Legendary }

UpgradeSlot_State :: enum{
    None, Focused, Selected
}

Upgrade_Value :: union{
    f32, bool
}

Upgrade :: struct{
    name : ui.UI_Text,
    desc : ui.UI_Text,
    value : Upgrade_Value,
    texture : rl.Color,
    rarity : Rarity,
    apply : Apply_Upgrade,
    check_condition : Check_Upgrade_Condition,
    target : Unlocked_Data_Type,
    type : Upgrade_Type,
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

create_upgrade_menu :: proc(m : ^UI_Upgrade_Menu, u : [dynamic]Upgrade){
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

get_random_upgrade_by_rarity :: proc(u : [dynamic]Upgrade, used_idx : [3]i32) -> (^Upgrade, i32){
    upgrade : ^Upgrade
    rand_idx : i32
    already_used_rarity : [dynamic]Rarity
    defer delete(already_used_rarity)
    rarity := get_random_rarity()

    for !check_if_upgrade_with_rarity(rarity, used_idx){
        append(&already_used_rarity, rarity)
        
        for check_if_rarity_already_checked(rarity, already_used_rarity[:]){
            rarity = get_random_rarity()
        }
    }

    for true{
        rand_idx = rand.int32_range(0, i32(len(u)))
        upgrade = &u[rand_idx]
        if upgrade.check_condition != nil && !upgrade.check_condition() do continue
        if upgrade.max_used > 0 && upgrade.count_used >= upgrade.max_used do continue
        if rarity != upgrade.rarity || is_upgrade_already_used(rand_idx, used_idx) do continue
        break
    }
    return upgrade, rand_idx
}

check_if_upgrade_with_rarity :: proc(r : Rarity, used_idx : [3]i32) -> bool{
    for u, idx in game.level.available_upgrades{
        if is_upgrade_already_used(i32(idx), used_idx) do continue
        if u.rarity == r do return true
    }
    return false
}

check_if_rarity_already_checked :: proc(r : Rarity, a : []Rarity) -> bool{
    for used_r in a{
        if r == used_r do return true
    }
    return false
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
    create_bomb_upgrades(a)

    create_bullet_upgrades(a)

    create_shard_upgrades(a)
}

create_upgrade :: proc(name : string, desc : string, value : Upgrade_Value, type : Upgrade_Type, rarity : Rarity) -> Upgrade{
        return {
            name = {
                content = name,
                halign = .Center,
                valign = .Center,
                font_size = 30,
                text_color = rl.WHITE,
            },
            desc = {
                content = desc,
                halign = .Center,
                valign = .Center,
                font_size = 30,
                text_color = rl.WHITE
            },
            value = value,
            type = type,
            rarity = rarity,
            target = .NormalBullet,
    }
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
        case .Common: return {180, 180, 255, 210}
        case .Uncommon: return {90, 90, 255, 220}
        case .Rare: return {0, 255, 0, 230}
        case .Epic: return {158, 90, 253, 235}
        case .Legendary: return {255, 165, 0, 255}
    }
    return rl.WHITE
}

get_upgrade_raster :: proc(r : Rarity) -> i32{
    switch r{
        case .Common: return 5
        case .Uncommon: return 7
        case .Rare: return 9
        case .Epic: return 11
        case .Legendary: return 15
    }
    return 5
}

apply_upgrade :: proc{
    apply_normal_upgrade,
    apply_toogle_upgrade,
}

apply_normal_upgrade :: proc(type : Upgrade_Type, stat : ^f32, v : f32){
    switch type{
        case .Additive:
            stat^ += v
        case .Multiplicative:
            stat^ *= v
        case .Subtrative:
            stat^ -= v
        case .Division:
            stat^ /= v
        case .Toogle:
    }
}

apply_toogle_upgrade :: proc(stat : ^bool, v : bool){
    stat^ = v
}