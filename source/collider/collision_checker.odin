package collider

import "core:fmt"
import rl "vendor:raylib"
import m "../map"

check_bullet_enemy :: proc(pos : rl.Vector2, radius : f32, rect : rl.Rectangle) -> (bool){
    return rl.CheckCollisionCircleRec(pos, radius, rect)
}

check_player_wall :: proc(pos_player : rl.Vector2, radius : f32, level : m.Tiled_Map, loaded : bool = false) -> bool{
    if !loaded{
        return false
    }
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

check_bullet_wall :: proc(pos_bullet : rl.Vector2, radius : f32, level : m.Tiled_Map) -> bool{
    for layer in level.layers{
        if layer.name != "Walls" do continue
        for obj in layer.objects{
            wall_rect := rl.Rectangle{
                x = obj.x,
                y = obj.y,
                width = obj.width,
                height = obj.height,
            }

            if rl.CheckCollisionCircleRec(pos_bullet, radius, wall_rect){
                return true
            }
        }
    }
    return false
}