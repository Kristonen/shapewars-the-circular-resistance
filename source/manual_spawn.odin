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

        enemy := e.Dummy_Enemy{
            height = 32,
            width = 48,
            pos = new_pos,
            speed = 200,
            color = rl.BEIGE,
            collidor = {
                height = 32,
                width = 48,
            },
            update_behavior = e.melee_enemy_behavior,
        }

        health := h.Health{
            current = 20,
            max = 20,
        }

        rect := rl.Rectangle{
            x = new_pos.x + 10,
            y = new_pos.y - 20,
            width = enemy.width + 20,
            height = 10,
        }

        enemy.health_bar = ui.create_progress_bar(rect, rl.BLACK, rl.GRAY, rl.RED)
        enemy.health = health

        return enemy, true
    }
    return {}, false
}