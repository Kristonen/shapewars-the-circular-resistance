package game

import "core:fmt"
import rl "vendor:raylib"
import "ui"

on_click_continue :: proc(g : ^Game_State){
    g.is_paused = !g.is_paused
}

on_click_options :: proc(g : ^Game_State){
    g.last_menu = g.menu
    g.menu = ui.create_menu(.Options)
}

on_click_back :: proc(g : ^Game_State){
    g.menu = g.last_menu
}

on_click_quit :: proc(g : ^Game_State){
    g.should_close = true
}