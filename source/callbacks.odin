package game

import "core:fmt"
import "ui"

on_click_continue :: proc(b : ui.UI_Button){
    game.is_paused = !game.is_paused
    game.current_menu = .Play
}

on_click_options :: proc(b : ui.UI_Button){
    game.last_menu = game.current_menu
    game.current_menu = .Options
    sync_menu()
}

on_click_back :: proc(b : ui.UI_Button){
    clear(&game.menu.elements)
    game.current_menu = game.last_menu
    sync_menu()
}

on_click_quit :: proc(b : ui.UI_Button){
    game.should_close = true
}

on_click_skilltree :: proc(b : ui.UI_Button){
    game.last_menu = game.current_menu
    if game.current_menu == .Catalyst{
        test := b.data.(^Skilltree_Ability_Type)
        game.active_skilltree = test^
    } else{
        test := b.data.(^Skilltree_Bullet_Type)
        game.active_skilltree = test^
    }
    game.current_menu = .Skilltree
    sync_menu()
}

on_click_change_level :: proc(b : ui.UI_Button){
    clear(&game.menu.elements)
    game.is_paused = !game.is_paused
    game.current_menu = .Play
    type := b.data.(^Level_Type)
    create_level(type^)
}

on_click_equiptment_menu :: proc(b : ui.UI_Button){
    game.last_menu = game.current_menu
    type := b.data.(Unlocked_Type)
    if type == .Weapon{
        game.current_menu = .EquiptmentBullet
    } else{
        game.current_menu = .EquiptmentAbility
    }
    sync_menu()
}

on_equip :: proc(b : ui.UI_Button){
    a := b.data.(Unlocked_Data_Type)
    switch a{
        case .NormalBullet:
        case .PierceBullet:
        case .Dash:
            game.player.ability = create_standard_dash()
            game.player.target_ability = .Dash
        case .RadialLiberation:
            game.player.ability = create_standard_radial_liberation()
            game.player.target_ability = .Radial_Liberation
    }
}

on_upgrade :: proc(u : ^Upgrade){
    u.count_used += 1
    u.apply(u^)
}