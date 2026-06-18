package game

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"
import cl "collider"
import "ui"

Enemy_Hit_Time :: 0.1

Behavior :: #type proc(e : ^Enemy, b : ^Behavior_Data, dt : f32)
On_Hit :: #type proc(e : ^Enemy, dmg : f32)
On_Death :: #type proc(e : Enemy, idx : i32)
// Apply_Knockback :: #type proc(k : ^Knockback, a_pos : rl.Vector2, v_pos : ^rl.Vector2)

Enemies : Enemy_List

Enemy_List :: struct{
    dummy_enemy : Enemy,

    begin_enemy : Enemy,
    begin_charge_enemy : Enemy,
    begin_distance_enemy : Enemy,
    viper_enemy : Enemy,
}

Melee_Data :: struct{

}

Distance_Data :: struct{
    max_distance : f32,
    bullet : Bullet,
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
    Melee_Data, Distance_Data, Charge_Data, Boss_Data
}

Enemy :: struct {
    rec : rl.Rectangle,
    origin : rl.Vector2,
    speed : f32,
    visual_scale : rl.Vector2,
    color : rl.Color,
    collidor : cl.Collider_Rectangle,
    behavior : Behavior_Data,
    behave : Behavior,

    health : Health,
    health_bar : ui.UI_Progress_Bar,

    knocback : Knockback,

    applied_status : [dynamic]Status_Effect,
    statuses : [dynamic]Status_Effect,

    spawner : rawptr,

    hit_timer : f32,

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
    apply : proc(k : ^Knockback, a_pos : rl.Vector2, v_pos : ^rl.Rectangle),
}

apply_knockback :: proc(k : ^Knockback, a_pos : rl.Vector2, rec : ^rl.Rectangle){
    pos : rl.Vector2 = {rec.x, rec.y}
    dir := pos - a_pos
    dir = rl.Vector2Normalize(dir)
    k.vel += dir * k.strength
}

apply_no_knockback :: proc(k : ^Knockback, a_pos : rl.Vector2, v_pos : ^rl.Rectangle){}


create_dummy_enemy :: proc() -> Enemy{
    e := create_enemy({width = 50, height = 40}, 50, 0, rl.ORANGE)
    e.health = {
        current = 100,
        max = 200,
        take_dmg = take_damage,
    }
    e.knocback = {
        // strength = 800,
        // friction = 0.99,
        // threshold = 4,
        // apply = apply_knockback,
        apply = apply_no_knockback,
    }
    e.behave = melee_enemy_behavior
    e.behavior = Melee_Data{}
    return e
}

create_melee_enemy :: proc(health, speed : f32, rec : rl.Rectangle, texture : rl.Color) -> Enemy{
    e := create_enemy(rec, health, speed, texture)
    e.knocback = {
        strength = 400,
        friction = 0.9,
        threshold = 10,
        apply = apply_knockback
    }
    e.behave = melee_enemy_behavior
    e.behavior = Melee_Data{}
    return e
}

create_distance_enemy :: proc(health, speed : f32, rec : rl.Rectangle, texture : rl.Color) -> Enemy{
    e := create_enemy(rec, health, speed, texture)
    e.behave = distance_enemy_behavior
    e.behavior = Distance_Data{
        max_distance = 350,
        weapon = {
            fire_rate = 1,
            bullet = create_bullet(8, 200, 5)
        }
    }
    return e
}

create_charge_enemy :: proc(health, speed : f32, rec : rl.Rectangle, texture : rl.Color) -> Enemy{
    e := create_enemy(rec, health, speed, texture)
    e.behave = charge_enemy_behavior
    e.behavior = Charge_Data{
        max_distance = 500,
        charge_time = 1,
        charge_speed = 750,
    }
    return e
}

create_enemy :: proc(rec : rl.Rectangle, health, speed : f32, color : rl.Color) -> Enemy{
    e := Enemy{
        rec = rec,
        speed = speed,
        color = color,
        visual_scale = {1, 1},
        on_hit = on_hit,
        on_death = on_death,
        health = {
            current = health,
            max = health,
            take_dmg = take_damage,
        }
    }
    e.collidor.rec = rec
    return e
}

on_hit :: proc(e : ^Enemy, dmg : f32){
    p_pos : rl.Vector2 = {e.rec.x + e.rec.width/2, e.rec.y + e.rec.height/2}
    play_sound_varied(audio_manager.enemy_hurt_sound, 0.5, 1.5)
    game.create_hit_particle(e.rec)
    // e.knocback->apply(game.player.pos, &e.rec)
    e.health->take_dmg(dmg)
    e.hit_timer = Enemy_Hit_Time
}

on_death :: proc(e : Enemy, idx : i32){
    game.shake = 50
    count := rand.int32_range(3, 7)
    spawn_shards(count, e.origin)
    if spawner := (^Spawner)(e.spawner); spawner != nil{
        spawner.count -= 1
    }
    health_rand := rand.float32()
    if health_rand < 0.2{
        spawn_health_pack(e.origin)
    }
    create_fragments_death(&game.level.enemy_fragments ,e)
    unordered_remove(&game.level.enemies, idx)
}

on_death_boss :: proc(e : Enemy, idx : i32){
    game.shake = 300
    game.level.state = .Finished
    // activate_portal(e.origin)
    unordered_remove(&game.level.enemies, idx)
}

on_death_poison :: proc(e : Enemy, idx : i32){
    game.shake = 50
    if spawner := (^Spawner)(e.spawner); spawner != nil{
        spawner.count -= 1
    }
    create_death_poison_particle(e.origin)
    p_area := Area_Effect{
        duration = 5,
        max_duration = 5,
        radius = 120,
        pos = e.origin,
        trigger = on_area_poison_trigger,
    }
    unordered_remove(&game.level.enemies, idx)
    append(&game.level.area_effects, p_area)
}

create_fragments_death :: proc(a : ^[dynamic]Enemy_Death_Fragment, e : Enemy){
    f : Enemy_Death_Fragment
    f.pos.x = e.rec.x
    f.pos.y = e.rec.y
    f.width = e.rec.width/2
    f.height = e.rec.height/2
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
    f.pos.x = e.rec.x
    f.speed = rand.float32_range(10, 100)
    f.life_time = rand.float32_range(3, 8)
    f.vel = {-1, 1}
    append(a, f)
}

melee_enemy_behavior :: proc(e : ^Enemy, d : ^Behavior_Data, dt : f32){
    data := d.(Melee_Data)
    dir := game.player.pos - {e.rec.x, e.rec.y}
    vel := rl.Vector2Normalize(dir) * e.speed
    new_pos : rl.Vector2 = {e.rec.x, e.rec.y}
    new_pos += vel * dt
    e.rec.x = new_pos.x
    e.rec.y = new_pos.y
}

distance_enemy_behavior :: proc(e : ^Enemy, d : ^Behavior_Data, dt : f32){
    data := &d.(Distance_Data)
    dist := rl.Vector2Distance({e.rec.x, e.rec.y}, game.player.pos)
    if data.max_distance <= dist{
        dir := game.player.pos - {e.rec.x, e.rec.y}
        vel := rl.Vector2Normalize(dir) * e.speed
        new_pos : rl.Vector2 = {e.rec.x, e.rec.y}
        new_pos += vel * dt
        e.rec.x = new_pos.x
        e.rec.y = new_pos.y
    } else if data.weapon.cooldown >= 0{
        data.weapon.cooldown -= dt
    } else{
        data.weapon.cooldown = data.weapon.fire_rate
        b := data.weapon.bullet
        pos := rl.Vector2{
            e.rec.x + e.rec.width/2, e.rec.y + e.rec.height/2
        }
        b.pos = pos
        dir := game.player.pos - {e.rec.x, e.rec.y}
        b.dir = rl.Vector2Normalize(dir)
        append(&game.level.enemy_bullets, b)
    }
}

charge_enemy_behavior :: proc(e : ^Enemy, d : ^Behavior_Data, dt : f32){
    data := &d.(Charge_Data)
    dist := rl.Vector2Distance(game.player.pos, {e.rec.x, e.rec.y})
    if data.max_distance <= dist && !data.is_charging{
        dir := game.player.pos - {e.rec.x, e.rec.y}
        vel := rl.Vector2Normalize(dir) * e.speed
        new_pos : rl.Vector2 = {e.rec.x, e.rec.y}
        new_pos += vel * dt
        e.rec.x = new_pos.x
        e.rec.y = new_pos.y
        return
    } else if !data.is_charging {
        data.is_charging = true
        data.charge_pos = game.player.pos
        data.charge_timer = data.charge_time
    }

    if data.is_charging && data.charge_timer > 0{
        data.charge_timer -= dt
        return
    }

    if data.is_charging{
        dir := data.charge_pos - {e.rec.x, e.rec.y}
        vel := rl.Vector2Normalize(dir) * data.charge_speed
        new_pos : rl.Vector2 = {e.rec.x, e.rec.y}
        new_pos += vel * dt
        e.rec.x = new_pos.x
        e.rec.y = new_pos.y
    }

    if data.is_charging && rl.Vector2Distance({e.rec.x, e.rec.y}, data.charge_pos) < 10{
        data.is_charging = false
    }
}

// check_enemy_use_ability :: proc(abilities : []Ability) -> bool{
//     for a in abilities{
//         if a.state != .None do return false
//     }
//     return true
// }

check_enemy_use_ability :: proc{
    check_enemy_use_boss_ability,
    check_other_enemy_data,
}

check_enemy_use_boss_ability :: proc(data : Boss_Data) -> bool{
    for a in data.abilities{
        if a.state != .None do return false
    }
    return true
}

check_other_enemy_data :: proc(data : Melee_Data) -> bool{
    return true
}