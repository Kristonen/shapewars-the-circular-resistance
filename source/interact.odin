package game

import rl "vendor:raylib"
import cl "collider"
import "ui"
//Struct that can be added to different entities in the game, the player can interact with the entity
Interactable :: struct{
    text : string,
    collider : cl.Collider_Circle,
    action : proc()
}
//Interaction with the portal
portal_interact :: proc(){
    game.level.portal.active = false
    create_level(.HQ)
}
//Interaction with the gunsmith
gunsmith_interact :: proc(){
    game.is_paused = !game.is_paused
    clear(&game.menu.elements)
    ui.create_menu(&game.menu)
    game.menu.color = {0, 0, 0, 255}
    game.current_menu = .Gunsmith
    sync_menu()
}
//Interaction with the commander
commander_interact :: proc(){
    game.is_paused = !game.is_paused
    clear(&game.menu.elements)
    ui.create_menu(&game.menu)
    game.menu.color = {0, 0, 0, 150}
    game.current_menu = .ChooseLevel
    sync_menu()
}
//Interaction with the catalyst
catalyst_interact :: proc(){
    game.is_paused = !game.is_paused
    clear(&game.menu.elements)
    ui.create_menu(&game.menu)
    game.menu.color = {0, 0, 0, 255}
    game.current_menu = .Catalyst
    sync_menu()
}