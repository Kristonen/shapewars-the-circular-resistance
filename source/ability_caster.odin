package game

import rl "vendor:raylib"

cast_player_ability :: proc(g : ^Game_State){
    switch &a in g.player.ability{
        case Radial_Liberation:
            cast_radial_liberation(a, &g.current_level.player_bullets, g.player.pos)
        case Dash:
    }
}