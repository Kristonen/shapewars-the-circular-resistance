package game

import rl "vendor:raylib"
import "ability"

cast_player_ability :: proc(g : ^Game_State){
    switch &a in g.player.ability{
        case ability.Radial_Liberation:
            ability.cast_radial_liberation(a, &g.player_bullets, g.player.pos)
        case ability.Dash:
    }
}