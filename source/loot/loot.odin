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
    speed : f32,
    dir : rl.Vector2,
    time : f32,


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
        new_shard.dir = {rand.float32_range(-1, 1), rand.float32_range(-1, 1)}
        new_shard.speed = f32(rand.int32_range(100, 200))
        new_shard.time = rand.float32_range(0.2, 0.5)
        
        give_shard_everything(&new_shard, pos)
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