package game

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"
import cl "collider"

Bomb_Idx :: 8
Bomb_Chance :: 0.25

Shard_Type :: enum {
    Low, Mid, High
}

LootCallback :: proc(l : ^Loot)
LootSpawn :: proc(l : ^Loot, dt : f32)
Loot_State :: enum{Spawning, Idle, Following, Collected}

Loot :: struct{
    rec : rl.Rectangle,
    // pos : rl.Vector2,
    // size : rl.Vector2,
    value : f32,
    // detection : cl.Collider_Circle,
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
    is_dead : bool,

    on_collect : LootCallback,
    on_spawn : LootSpawn,
    state : Loot_State,
}

create_simple_shard :: proc(drops : ^[dynamic]Loot, pos : rl.Vector2){
    shard : Loot
    give_shard_everything(&shard, pos)
    shard.is_active = true
    append(drops, shard)
}

spawn_shards :: proc(count : i32, pos : rl.Vector2){
    for _ in 0..<count{
        new_shard : Loot
        new_shard.dir = {rand.float32_range(-1, 1), rand.float32_range(-1, 1)}
        new_shard.speed = f32(rand.int32_range(100, 200))
        new_shard.time = rand.float32_range(0.2, 0.5)
        
        give_shard_everything(&new_shard, pos)
        append(&game.level.loot, new_shard)
    }
}

spawn_health_pack :: proc(pos : rl.Vector2){
    health_pack : Loot
    give_shard_everything(&health_pack, pos)
    health_pack.value = 5
    health_pack.color = rl.LIME
    health_pack.on_collect = on_health_pack_collect
    health_pack.rec.width = 50
    health_pack.rec.height = 70
    append(&game.level.loot, health_pack)
}

spawn_bomb_blueprint :: proc(pos : rl.Vector2){
    bp : Loot
    give_shard_everything(&bp, pos)
    bp.value = Bomb_Idx
    bp.color = rl.DARKBLUE
    bp.rec.width = 100
    bp.rec.height = 100
    bp.on_collect = on_blueprint_collect
    append(&game.level.loot, bp)
}

give_shard_everything :: proc(shard : ^Loot, pos : rl.Vector2){
    shard.max_speed = 600
    shard.acceleration = 2
    shard.rec.x = pos.x
    shard.rec.y = pos.y
    shard.rec.width = 20
    shard.rec.height = 20
    // shard.detection.pos = {shard.rec.x + shard.rec.width/2, shard.rec.y + shard.rec.height/2}
    // shard.detection.radius = shard.rec.width * 6
    shard.pickup.pos = {shard.rec.x + shard.rec.width/2, shard.rec.y + shard.rec.height/2}
    shard.pickup.radius = shard.rec.width / 4
    shard.on_collect = on_shard_collect
    shard.on_spawn = on_normal_spawn
    shard.state = .Spawning

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

on_shard_collect :: proc(l : ^Loot){
    game.player.loot_bag->increase_value(l.value)
}

on_health_pack_collect :: proc(l : ^Loot){
    game.player.health.heal_amount += l.value
}

on_blueprint_collect :: proc(l : ^Loot){
    idx := i32(l.value)
    u := &game.unlockables[idx]
    u.blueprints += 1
}

on_normal_spawn :: proc(l : ^Loot, dt : f32){
    l.time -= dt
    if l.time <= 0{
        l.state = .Idle
        // l.is_active = true
        return
    }
    l.rec.x += l.dir.x * l.speed * dt
    l.rec.y += l.dir.y * l.speed * dt
    // l.detection.pos = {l.rec.x + l.rec.width/2, l.rec.y + l.rec.height/2}
    l.pickup.pos = {l.rec.x + l.rec.width/2, l.rec.y + l.rec.height/2}
}