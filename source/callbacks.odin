package game

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

on_upgrade :: proc(u : ^Upgrade){
    u.count_used += 1
    u.apply(u^)
}