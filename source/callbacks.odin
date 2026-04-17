package game

import "core:fmt"
import "upgrade"
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

on_upgrade :: proc(g : ^Game_State, u : ^upgrade.Upgrade){
    u.count_used += 1
    stat : ^upgrade.Upgrade_Value
    if u.target == .Player{
        switch u.stat{
            case .Damage:
                stat = (^upgrade.Upgrade_Value)(&g.player.weapon.bullet.damage)
            case .Move_Speed:
                stat = (^upgrade.Upgrade_Value)(&g.player.speed)
            case .Attack_Speed:
                stat = (^upgrade.Upgrade_Value)(&g.player.weapon.fire_rate)
            case .Health:
                stat = (^upgrade.Upgrade_Value)(&g.player.health.max)
            case .Amount:
            case .Lifesteal:
                stat = (^upgrade.Upgrade_Value)(&g.player.weapon.lifesteal)
        }
    } else{
        switch &a in g.player.ability{
        case ability.Radial_Liberation:
            if u.type == .Toogle{
                switch u.toogle_target{
                    case .Pierce:
                    case .LifeStealAbility:
                        stat = (^upgrade.Upgrade_Value)(&a.can_lifesteal)
                }
            } else {
                switch u.stat{
                case .Damage:
                    stat = (^upgrade.Upgrade_Value)(&a.damage)
                case .Attack_Speed:
                    stat = (^upgrade.Upgrade_Value)(&g.player.weapon.lifesteal)
                case .Move_Speed:
                case .Health:
                case .Amount:
                    stat = (^upgrade.Upgrade_Value)(&a.count)
                case .Lifesteal:
                    stat = (^upgrade.Upgrade_Value)(&g.player.weapon.lifesteal)
                }
            }
            case ability.Dash:
        }
    }

    
    apply_upgrade(u.type, stat, u.value)
}

apply_upgrade :: proc(type : upgrade.Upgrade_Type, stat : ^upgrade.Upgrade_Value, value : upgrade.Upgrade_Value){
    switch type{
        case .Additive:
            additive_upgrade((^f32)(stat), value.(f32))
        case .Subtrative:
        case .Multiplicative:
            multiplicative_upgrade((^f32)(stat), value.(f32))
        case .Division:
        case .Toogle:
            toogle_upgrade((^bool)(stat), value.(bool))
    }
}

additive_upgrade :: proc(stat : ^f32, value : f32){
    fmt.println(value)
    stat^ += value
}

multiplicative_upgrade :: proc(stat : ^f32, value : f32){
    stat^ *= value
}

toogle_upgrade :: proc(stat : ^bool, value : bool){
    stat^ = value
}