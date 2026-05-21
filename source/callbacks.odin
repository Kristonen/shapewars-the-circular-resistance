package game

import "core:fmt"
import "ui"
import rl "vendor:raylib"

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
    type := b.data.(Unlocked_Data_Type)
    game.active_skilltree = type
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

on_click_select_craftable :: proc(b : ui.UI_Button){
    type := b.data.(Unlocked_Data_Type)

    for &e in game.menu.elements{
        if btn, ok := &e.(ui.UI_Button); ok && btn.text.content == "Buy"{
            ui.change_button_data(btn, type)
            btn.show = true
            u := get_unlockable(type)
            btn.disabled = u.blueprints < 1
        }
    }
    refresh_ui_pointers()
}

on_click_craft :: proc(b : ui.UI_Button){
    type := b.data.(Unlocked_Data_Type)
    u := get_unlockable(type)
    u.blueprints -= 1
    game.shards -= u.cost
    if !u.unlocked do u.unlocked = true
}

on_equip :: proc(b : ui.UI_Button){
    type := b.data.(Unlocked_Data_Type)
    if type == game.player.current_weapon || type == game.player.current_ability do return
    switch type{
        case .NormalBullet:
            game.player.current_weapon = type
        case .PierceBullet:
            game.player.current_weapon = type
        case .Dash:
            game.player.current_ability = .Dash
        case .Radial_Liberation:
            game.player.current_ability = .Radial_Liberation
        case .Bomb:
            game.player.current_ability = .Bomb
    }
    switch_weapon()
    switch_ability()
}

on_upgrade :: proc(u : ^Upgrade){
    u.count_used += 1
    u.apply(u^)
}