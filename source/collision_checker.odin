package game

import rl "vendor:raylib"

check_bullet_enemy :: proc(b : Bullet, e : Dummy_Enemy) -> (bool){
    enemy_rectangle := rl.Rectangle{
        x = e.pos.x,
        y = e.pos.y,
        width = e.width,
        height = e.height,
    }

    if rl.CheckCollisionCircleRec(b.pos, b.radius, enemy_rectangle){
        return true
    }

    return false
}

check_player_wall :: proc(pos_player : rl.Vector2, radius : f32, level : Tiled_Map) -> bool{
    for layer in level.layers{
        if layer.name == "Walls"{
            for obj in layer.objects{
                wall_rect := rl.Rectangle{
                    x = obj.x,
                    y = obj.y,
                    width = obj.width,
                    height = obj.height,
                }
                if rl.CheckCollisionCircleRec(pos_player, radius, wall_rect){
                    return true
                }
            }
        }
    }
    return false
}