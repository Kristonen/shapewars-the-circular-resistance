package game

import "core:fmt"
import rl "vendor:raylib"
import "upgrade"
import "player"
import "ability"

on_click_continue :: proc(g : ^Game_State){
    g.is_paused = !g.is_paused
}

on_click_options :: proc(g : ^Game_State){
    g.last_menu = g.current_menu
    g.current_menu = .Options
    sync_menu(g)
}

on_click_back :: proc(g : ^Game_State){
    clear(&g.menu.elements)
    g.current_menu = g.last_menu
    sync_menu(g)
}

on_click_quit :: proc(g : ^Game_State){
    g.should_close = true
}

on_upgrade :: proc(g : ^Game_State, u : upgrade.Upgrade){
    if u.target == .Player{
        switch u.stat{
            case .Damage:
                apply_upgrade(u.type, &g.player.bullet.damage, u.value)
            case .Move_Speed:
                apply_upgrade(u.type, &g.player.speed, u.value)
            case .Attack_Speed:
                apply_upgrade(u.type, &g.player.weapon.fire_rate, u.value)
            case .Health:
                apply_upgrade(u.type, &g.player.health.max, u.value)
            case .Amount:
        }
        return
    }

    switch &a in g.player.ability{
        case ability.Radial_Liberation:
            switch u.stat{
                case .Damage:
                    apply_upgrade(u.type, &a.damage, u.value)
                    fmt.println(a.damage)
                case .Attack_Speed:
                case .Move_Speed:
                case .Health:
                case .Amount:
                    apply_upgrade(u.type, &a.count, u.value)
            }
    }
}

apply_upgrade :: proc(type : upgrade.Upgrade_Type, stat : ^f32, value : f32){
    switch type{
        case .Additive:
            additive_upgrade(stat, value)
        case .Subtrative:
        case .Multiplicative:
            multiplicative_upgrade(stat, value)
        case .Division:
    }
}

additive_upgrade :: proc(stat : ^f32, value : f32){
    stat^ += value
}

multiplicative_upgrade :: proc(stat : ^f32, value : f32){
    stat^ *= value
}