package handler

import rl "vendor:raylib"

Camera_World :: struct{
    top : f32,
    right : f32,
    bottom : f32,
    left : f32,
}

get_camera_world_position :: proc(c : rl.Camera2D) -> Camera_World{
    camera_world : Camera_World

    camera_world.left = c.target.x - (c.offset.x / c.zoom)
    camera_world.right = c.target.x + (c.offset.x / c.zoom)
    camera_world.top = c.target.y - (c.offset.y / c.zoom)
    camera_world.bottom = c.target.y + (c.offset.y / c.zoom)

    return camera_world
}