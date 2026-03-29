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

        health := Health{
            current = 50,
            max = 100,
        }

        bar := Health_Bar{
            rect = {x = enemy.pos.x - 10, y = enemy.pos.y - 20, width = enemy.width + 20, height = 15},
            outline_color = rl.BLACK,
            background_color = rl.GRAY,
            fill_color = rl.RED,
        }
        enemy.health = health
        enemy.health_bar = bar

        return enemy, true
    }
    return {}, false
}