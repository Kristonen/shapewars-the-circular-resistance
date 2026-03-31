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

get_camera_follow_pos :: proc(pos : rl.Vector2, c : rl.Camera2D, dt : f32) -> rl.Vector2{
    lerp_speed : f32 = 5.0
    follow_pos : rl.Vector2
    
    follow_pos.x += (pos.x - c.target.x) * lerp_speed * dt
    follow_pos.y += (pos.y - c.target.y) * lerp_speed * dt
    
    return follow_pos
}