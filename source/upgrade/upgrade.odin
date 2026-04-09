package upgrade

import "core:math/rand"
import rl "vendor:raylib"

Upgrade_Target :: enum { Player, Radial_Liberation }
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

create_upgrade_menu :: proc(m : ^UI_Upgrade_Menu, u : [dynamic]Upgrade){
    m.width = f32(rl.GetScreenWidth())
    m.height = f32(rl.GetScreenHeight())
    // m.upgrades = create_test_upgrades()
    for i in 0..<3{
        rand := rand.int32_range(0, i32(len(u)))
        m.upgrades[i] = create_upgrade_slot(u[rand], f32(i))
    }
    shader := rl.LoadShader(nil, "assets/test.frag")
    u_time_loc := rl.GetShaderLocation(shader, "u_time")
    color_loc := rl.GetShaderLocation(shader, "color")

    m.shader.bloom = shader
    m.shader.u_time_loc = u_time_loc
    m.shader.color_loc = color_loc
    m.shader.timer = 0.5
}

create_upgrades :: proc(a : ^[dynamic]Upgrade){
    create_dmg_upgrades(a)
    create_movement_speed_upgrades(a)
    create_as_upgrades(a)
    create_health_upgrades(a)
    create_rl_upgrades(a)
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
        color = {130, 130, 130, 150},
    }
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