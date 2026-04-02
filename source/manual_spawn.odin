package game

import rl "vendor:raylib"
import e "enemy"
import h "health"
import "ui"
import "handler"

update_spawn :: proc(game : ^Game_State) -> (e.Dummy_Enemy, bool){
    
    if rl.IsKeyPressed(.T){
        // new_pos := rl.Vector2{game.player.pos.x + 50, game.player.pos.y + 50}
        new_pos := handler.get_random_spawn_pos(game.camera)

        enemy := e.create_enemy(new_pos)

        return enemy, true
    }
    return {}, false
}