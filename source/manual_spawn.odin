package game

import rl "vendor:raylib"
import e "enemy"
import h "health"
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
            current = 90,
            max = 100,
        }
        rect := rl.Rectangle{
            x = new_pos.x,
            y = new_pos.y,
            width = enemy.width,
            height = enemy.height
        }
        enemy.health_bar = h.create_health_bar(rect, health, rl.BLACK, rl.GRAY, rl.RED)
        enemy.health = health

        return enemy, true
    }
    return {}, false
}