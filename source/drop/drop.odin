package drop

import rl "vendor:raylib"
import cl "../collider"


Shape_Shard :: struct{
    pos : rl.Vector2,
    value : f32,
    radius : f32,
    detection : cl.Collider_Circle,
    pickup : cl.Collider_Circle,
    color : rl.Color,

    current_speed : f32,
    max_speed : f32,
    acceleration : f32,
    is_following : bool,
}

create_shape_shard :: proc(pos : rl.Vector2) -> Shape_Shard{
    shard : Shape_Shard
    shard.max_speed = 600
    shard.acceleration = 2
    shard.pos = pos
    shard.value = 10
    shard.radius = 15
    shard.detection.pos = pos
    shard.detection.radius = shard.radius * 4
    shard.pickup.pos = pos
    shard.pickup.radius = shard.radius / 2
    shard.color = rl.GOLD
    return shard
}

update_loot :: proc(s : ^Shape_Shard, target : rl.Vector2, dt : f32){
    if !s.is_following do return
    dir := target - s.pos
    dir = rl.Vector2Normalize(dir)

    if s.current_speed <= s.max_speed{
        s.current_speed += s.acceleration
    }
    s.pos += dir * s.current_speed * dt
    s.detection.pos = s.pos
    s.pickup.pos = s.pos
}

draw_loot :: proc(s : Shape_Shard){
    rl.DrawCircleV(s.pos, s.radius, s.color)
}