package handler

import "core:math/rand"
import rl "vendor:raylib"
import "core:fmt"

Spawn_Dir :: enum{
    Top, Right, Bottom, Left
}

get_random_spawn_pos :: proc(c : rl.Camera2D) -> rl.Vector2{
    c_world := get_camera_world_position(c)
    distance : f32 = 50
    pos : rl.Vector2
    spawn_dir := get_random_dir()
    switch spawn_dir{
        case .Top:
            pos.x = f32(rand.int_range(int(c_world.left) ,int(c_world.right)))
            pos.y = c_world.top - distance
        case .Right:
                pos.x = c_world.right + distance
                pos.y = f32(rand.int_range(int(c_world.top), int(c_world.bottom)))
        case .Bottom:
            pos.x = f32(rand.int_range(int(c_world.left) ,int(c_world.right)))
            pos.y = c_world.bottom + distance
        case .Left:
            pos.x = c_world.left - distance
            pos.y = f32(rand.int_range(int(c_world.top), int(c_world.bottom)))
    }
    return pos
}

get_random_dir :: proc() -> Spawn_Dir{
    dir : Spawn_Dir

    rand_numb := rand.int_max(len(Spawn_Dir))

    return Spawn_Dir(rand_numb)
}
