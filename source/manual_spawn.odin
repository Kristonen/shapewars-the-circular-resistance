package game

import rl "vendor:raylib"

update_spawn :: proc(game : ^Game_State) -> (Dummy_Enemy, bool){
    
    if rl.IsKeyPressed(.T){
        new_pos := rl.Vector2{game.player.pos.x + 50, game.player.pos.y + 50}
        enemy := Dummy_Enemy{
            height = 32,
            width = 48,
            pos = new_pos,
            color = rl.BEIGE,
            collidor = {
                type = .Rec,
                height = 32,
                width = 48,
            }
        }
        return enemy, true
    }
    return {}, false
}