package game

on_click_continue :: proc(){
    game.is_paused = !game.is_paused
}

on_click_options :: proc(){
    game.last_menu = game.current_menu
    game.current_menu = .Options
    sync_menu()
}

on_click_back :: proc(){
    clear(&game.menu.elements)
    game.current_menu = game.last_menu
    sync_menu()
}

on_click_quit :: proc(){
    game.should_close = true
}

on_click_btn_skilltree :: proc(){
    game.last_menu = game.current_menu
    game.current_menu = .Skilltree
    sync_menu()
}

on_upgrade :: proc(u : ^Upgrade){
    u.count_used += 1
    u.apply(u^)
}