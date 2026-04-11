package game

import "core:math/rand"
import rl "vendor:raylib"
import cl "collider"
import "ui"
import "loot"

Enemy_Behavior :: #type proc(e : ^Dummy_Enemy, player_pos : rl.Vector2, dt : f32)
On_Hit :: #type proc(g : ^Game_State, e : ^Dummy_Enemy, dmg : f32)
On_Death :: #type proc(g : ^Game_State, e : Dummy_Enemy, idx : i32)
Dummy_Enemy :: struct {
    pos : rl.Vector2,
    origin : rl.Vector2,
    speed : f32,
    width : f32,
    height : f32,
    visual_scale : rl.Vector2,
    color : rl.Color,
    collidor : cl.Collider_Rectangle,
    update_behavior : Enemy_Behavior,

    health : Health,
    health_bar : ui.UI_Progress_Bar,
    knocback : Knockback,

    spawner : rawptr,

    on_hit : On_Hit,
    on_death : On_Death,
}

Enemy_Death_Fragment :: struct{
    pos : rl.Vector2,
    width : f32,
    height : f32,
    vel : rl.Vector2,
    speed : f32,
    color : rl.Color,
    life_time : f32,
    move_time : f32,
}

Knockback :: struct{
    strength : f32,
    vel : rl.Vector2,
    threshold : f32,
    friction : f32,
    apply : proc(k : ^Knockback, a_pos : rl.Vector2, v_pos : ^rl.Vector2),
}

apply_knockback :: proc(k : ^Knockback, a_pos : rl.Vector2, v_pos : ^rl.Vector2){
    dir := v_pos^ - a_pos
    dir = rl.Vector2Normalize(dir)
    k.vel += dir * k.strength
}

create_enemy :: proc(pos : rl.Vector2) -> Dummy_Enemy{
    enemy := Dummy_Enemy{
        height = 32,
        width = 48,
        pos = pos,
        speed = 200,
        color = rl.RED,
        collidor = {
            height = 32,
            width = 48,
        },
        update_behavior = melee_enemy_behavior,
        knocback = {
            strength = 400,
            friction = 0.9,
            threshold = 10,
            apply = apply_knockback,
        },
        visual_scale = {1, 1},
    }

    health := Health{
        current = 25,
        max = 25,
        take_dmg = take_damage,
    }

    rect := rl.Rectangle{
        x = pos.x + 20,
        y = pos.y - 20,
        width = enemy.width + 20,
        height = 10,
    }

    enemy.health = health
    enemy.health_bar = ui.create_progress_bar(rect, rl.BLACK, rl.GRAY, rl.RED)
    enemy.health_bar.value = enemy.health.current
    enemy.health_bar.max = enemy.health.max
    enemy.origin = {enemy.pos.x + enemy.width/2, enemy.pos.y + enemy.height/2}
    enemy.on_hit = on_hit
    enemy.on_death = on_death

    return enemy
}

on_hit :: proc(g : ^Game_State, e : ^Dummy_Enemy, dmg : f32){
    p_pos : rl.Vector2 = {e.pos.x + e.width/2, e.pos.y + e.height/2}
    g.create_hit_particle(&g.particles, e.origin)
    e.knocback->apply(g.player.pos, &e.pos)
    e.health->take_dmg(dmg)
}

on_death :: proc(g : ^Game_State, e : Dummy_Enemy, idx : i32){
    g.shake = 100
    count := rand.int32_range(3, 7)
    loot.spawn_shards(&g.loot, count, e.origin)
    spawner : ^Spawner = (^Spawner)(e.spawner)
    spawner.count -= 1
    create_fragments_death(&g.enemy_fragments ,e)
    unordered_remove(&g.enemies, idx)
}

create_fragments_death :: proc(a : ^[dynamic]Enemy_Death_Fragment, e : Dummy_Enemy){
    f : Enemy_Death_Fragment
    f.pos.x = e.pos.x
    f.pos.y = e.pos.y
    f.width = e.width/2
    f.height = e.height/2
    f.speed = rand.float32_range(10, 20)
    f.life_time = rand.float32_range(3, 5)
    f.move_time = 0.25
    f.vel = {-1, -1}
    f.color = e.color
    append(a, f)
    f.pos.x += f.width
    f.speed = rand.float32_range(10, 100)
    f.life_time = rand.float32_range(3, 8)
    f.vel = {1, -1}
    append(a, f)
    f.pos.y += f.height
    f.speed = rand.float32_range(10, 100)
    f.life_time = rand.float32_range(3, 8)
    f.vel = {1, 1}
    append(a, f)
    f.pos.x = e.pos.x
    f.speed = rand.float32_range(10, 100)
    f.life_time = rand.float32_range(3, 8)
    f.vel = {-1, 1}
    append(a, f)
}

melee_enemy_behavior :: proc(e : ^Dummy_Enemy, player_pos : rl.Vector2, dt : f32){
    dir := player_pos - e.pos
    vel := rl.Vector2Normalize(dir) * e.speed
    e.pos += vel * dt
}