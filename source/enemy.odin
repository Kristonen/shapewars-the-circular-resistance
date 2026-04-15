package game

import "core:math/rand"
import rl "vendor:raylib"
import cl "collider"
import "ui"
import "loot"
import "bullet"

Behavior :: #type proc(g : ^Game_State, e : ^Enemy, $T : typeid)
On_Hit :: #type proc(g : ^Game_State, e : ^Enemy, dmg : f32)
On_Death :: #type proc(g : ^Game_State, e : Enemy, idx : i32)

Melee_Data :: struct{

}

Distance_Data :: struct{
    max_distance : f32,
    bullet : bullet.Bullet,
    weapon : Weapon,
}

Charge_Data :: struct{
    max_distance : f32,
    charge_time : f32,
    charge_timer : f32,
    charge_speed : f32,
    is_charging : bool,
    charge_pos : rl.Vector2,
}

Behavior_Data :: union{
    Melee_Data, Distance_Data, Charge_Data
}

Enemy :: struct {
    pos : rl.Vector2,
    origin : rl.Vector2,
    speed : f32,
    width : f32,
    height : f32,
    visual_scale : rl.Vector2,
    color : rl.Color,
    collidor : cl.Collider_Rectangle,
    behavior : Behavior_Data,

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

create_start_enemy :: proc(rect : rl.Rectangle, speed : f32, color : rl.Color) -> Enemy{
    e := create_enemy(rect, speed, color)
    e.health = {
        current = 25,
        max = 25,
        take_dmg = take_damage,
    }
    e.knocback = {
        strength = 400,
        friction = 0.9,
        threshold = 10,
        apply = apply_knockback,
    }
    e.behavior = Melee_Data{}
    return e
}

create_second_enemy :: proc() -> Enemy{
    rect := rl.Rectangle{width = 40, height = 24}
    e := create_enemy(rect, 100, rl.GOLD)
    e.health = {
        current = 10,
        max = 10,
        take_dmg = take_damage,
    }
    e.knocback = {
        strength = 500,
        friction = 0.8,
        threshold = 10,
        apply = apply_knockback,
    }
    e.behavior = Distance_Data{
        max_distance = 350,
        weapon = {
            fire_rate = 1,
            bullet = bullet.create_bullet()
        }
    }
    return e
}

create_third_enemy :: proc() -> Enemy{
    e := create_enemy({width = 64, height = 54}, 300, rl.BROWN)
    e.health = {
        current = 100,
        max = 100,
        take_dmg = take_damage,
    }
    e.knocback = {
        strength = 100,
        friction = 0.95,
        threshold = 10,
        apply = apply_knockback,
    }
    e.behavior = Charge_Data{
        max_distance = 500,
        charge_time = 1,
        charge_speed = 750,
    }
    return e
}

create_enemy :: proc(rect : rl.Rectangle, speed : f32, color : rl.Color) -> Enemy{
    e := Enemy{
        width = rect.width,
        height = rect.height,
        speed = speed,
        color = color,
        visual_scale = {1, 1},
        on_hit = on_hit,
        on_death = on_death,
    }
    e.collidor = { width = e.width, height = e.height}
    return e
}

on_hit :: proc(g : ^Game_State, e : ^Enemy, dmg : f32){
    p_pos : rl.Vector2 = {e.pos.x + e.width/2, e.pos.y + e.height/2}
    g.create_hit_particle(&g.current_level.particles, e.origin)
    e.knocback->apply(g.player.pos, &e.pos)
    e.health->take_dmg(dmg)
}

on_death :: proc(g : ^Game_State, e : Enemy, idx : i32){
    g.shake = 100
    count := rand.int32_range(3, 7)
    loot.spawn_shards(&g.current_level.loot, count, e.origin)
    if spawner := (^Spawner)(e.spawner); spawner != nil{
        spawner.count -= 1
    }
    // spawner : ^Spawner = (^Spawner)(e.spawner)
    // spawner.count -= 1
    create_fragments_death(&g.current_level.enemy_fragments ,e)
    unordered_remove(&g.current_level.enemies, idx)
}

create_fragments_death :: proc(a : ^[dynamic]Enemy_Death_Fragment, e : Enemy){
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

melee_enemy_behavior :: proc(e : ^Enemy, data : Melee_Data, player_pos : rl.Vector2, dt : f32){
    dir := player_pos - e.pos
    vel := rl.Vector2Normalize(dir) * e.speed
    e.pos += vel * dt
}

distance_enemy_behavior :: proc(e : ^Enemy, data : ^Distance_Data, g : ^Game_State, dt : f32){
    dist := rl.Vector2Distance(e.pos, g.player.pos)
    if data.max_distance <= dist{
        dir := g.player.pos - e.pos
        vel := rl.Vector2Normalize(dir) * e.speed
        e.pos += vel * dt
    } else if data.weapon.cooldown >= 0{
        data.weapon.cooldown -= dt
    } else{
        data.weapon.cooldown = data.weapon.fire_rate
        b := data.weapon.bullet
        pos := rl.Vector2{
            e.pos.x + e.width/2, e.pos.y + e.height/2
        }
        b.pos = pos
        dir := g.player.pos - e.pos
        b.dir = rl.Vector2Normalize(dir)
        append(&g.current_level.enemy_bullets, b)
    }
}

charge_enemy_behavior :: proc(e : ^Enemy, data : ^Charge_Data, g : ^Game_State, dt : f32){
    dist := rl.Vector2Distance(g.player.pos, e.pos)
    if data.max_distance <= dist && !data.is_charging{
        dir := g.player.pos - e.pos
        vel := rl.Vector2Normalize(dir) * e.speed
        e.pos += vel * dt
        return
    } else if !data.is_charging {
        data.is_charging = true
        data.charge_pos = g.player.pos
        data.charge_timer = data.charge_time
    }

    if data.is_charging && data.charge_timer > 0{
        data.charge_timer -= dt
        return
    }

    if data.is_charging{
        dir := data.charge_pos - e.pos
        vel := rl.Vector2Normalize(dir) * data.charge_speed
        e.pos += vel * dt
    }

    if data.is_charging && rl.Vector2Distance(e.pos, data.charge_pos) < 10{
        data.is_charging = false
    }
}