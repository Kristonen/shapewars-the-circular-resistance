package game

import rl "vendor:raylib"
import cl "collider"
import "ui"

Interactable :: struct{
    text : string,
    collider : cl.Collider_Circle,
    action : proc()
}

gunsmith_interact :: proc(){
    game.is_paused = !game.is_paused
    clear(&game.menu.elements)
    ui.create_menu(&game.menu)
    game.menu.color = {0, 0, 0, 255}
    game.current_menu = .Gunsmith
    sync_menu()
}

commander_interact :: proc(){
    game.is_paused = !game.is_paused
    clear(&game.menu.elements)
    ui.create_menu(&game.menu)
    game.menu.color = {0, 0, 0, 150}
    game.current_menu = .ChooseLevel
    sync_menu()
}