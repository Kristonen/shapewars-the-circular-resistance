package game

import rl "vendor:raylib"

cast_player_ability :: proc(){
    switch &a in game.player.ability{
        case Radial_Liberation:
            cast_radial_liberation(a, &game.current_level.player_bullets, game.player.pos)
        case Dash:
    }
}