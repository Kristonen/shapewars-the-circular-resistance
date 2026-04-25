package game

import "ui"

// check_which_btn_was_pressed :: proc(b : ^ui.UI_Button){
//     b.state = .None
//     switch b.type{
//         case .Continue:
//             on_click_continue(b^)
//         case .Options:
//             on_click_options(b^)
//         case .Back:
//             on_click_back(b^)
//         case .Exit:
//             on_click_quit(b^)
//         case .Skilltree:
//             on_click_btn_skilltree(b^)
//     }
// }

on_click_continue :: proc(b : ui.UI_Button){
    game.is_paused = !game.is_paused
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
    game.current_menu = .Skilltree
    sync_menu()
}

on_click_change_level :: proc(b : ui.UI_Button){
    clear(&game.menu.elements)
    game.is_paused = !game.is_paused
    type := b.data.(^Level_Type)
    create_level(type^)
}

on_upgrade :: proc(u : ^Upgrade){
    u.count_used += 1
    u.apply(u^)
}