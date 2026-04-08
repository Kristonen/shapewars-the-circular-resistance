package loot

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"
import cl "../collider"

Shard_Type :: enum {
    Low, Mid, High
}

Shape_Shard :: struct{
    pos : rl.Vector2,
    value : f32,
    size : rl.Vector2,
    detection : cl.Collider_Circle,
    pickup : cl.Collider_Circle,
    color : rl.Color,

    //Drop
    vel : rl.Vector2,
    rotation : f32,
    rot_speed : f32,


    current_speed : f32,
    max_speed : f32,
    acceleration : f32,
    is_following : bool,
    is_active : bool,
}

create_simple_shard :: proc(drops : ^[dynamic]Shape_Shard, pos : rl.Vector2){
    shard : Shape_Shard
    give_shard_everything(&shard, pos)
    shard.is_active = true
    append(drops, shard)
}

spawn_shards :: proc(drops : ^[dynamic]Shape_Shard, count : i32, pos : rl.Vector2){
    for _ in 0..<count{
        new_shard : Shape_Shard
        angle := rand.float32_range(0, math.PI * 2)
        force := rand.float32_range(500, 1500)
        velocity := rl.Vector2{
            math.cos(angle) * force, math.sin(angle) * force
        }
        give_shard_everything(&new_shard, pos)
        new_shard.vel = velocity
        new_shard.rotation = rand.float32_range(0, 360.0)
        new_shard.rot_speed = rand.float32_range(-200, 200)
        append(drops, new_shard)
    }
}

give_shard_everything :: proc(shard : ^Shape_Shard, pos : rl.Vector2){
    shard.max_speed = 600
    shard.acceleration = 2
    shard.pos = pos
    shard.value = 10
    shard.size = {20, 20}
    shard.detection.pos = {shard.pos.x + shard.size.x/2, shard.pos.y + shard.size.y/2}
    shard.detection.radius = shard.size.x * 6
    shard.pickup.pos = {shard.pos.x + shard.size.x/2, shard.pos.y + shard.size.y/2}
    shard.pickup.radius = shard.size.x / 4

    roll := rand.float32()
    if roll < 0.05{
        shard.value = 50
        shard.color = rl.BROWN
    } else if roll < 0.15 {
        shard.value = 25
        shard.color = rl.VIOLET
    } else if roll < 0.35 {
        shard.value = 20
        shard.color = rl.LIME
    } else {
        shard.value = 10
        shard.color = rl.GOLD
    }
}

update_loot :: proc(s : ^Shape_Shard, target : rl.Vector2, dt : f32){
    s.detection.pos = s.pos
    s.pickup.pos = s.pos
    s.pos += s.vel * dt
    s.vel *= 0.94
    s.rotation += s.rot_speed * dt
    s.rot_speed *= 0.96
    speed_sq := s.vel.x * s.vel.x + s.vel.y * s.vel.y
    if speed_sq < 0.5{
        s.vel = {}
        s.rot_speed = 0
        s.is_active = true
    }

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
    dest := rl.Rectangle{s.pos.x, s.pos.y, s.size.x, s.size.y}
    origin := rl.Vector2{s.size.x / 2, s.size.y / 2}
    rl.DrawRectanglePro(dest, origin, s.rotation, s.color)
}