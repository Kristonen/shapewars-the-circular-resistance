package game

import rl "vendor:raylib"

activate_helper :: proc(g : ^Game_State){
    if rl.IsKeyPressed(.F2){
        g.helper_activated = !g.helper_activated
    }
}