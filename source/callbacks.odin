package game

import "core:fmt"
import rl "vendor:raylib"
import "ui"

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