package player

import "core:fmt"
import rl "vendor:raylib"
import ab "../ability"
import cl "../collider"
import m "../map"
import h "../health"
import b "../bullet"
import "../ui"

Weapon :: struct {
    fire_rate : f32,
    cooldown : f32,
}

Loot_Bag :: struct{
    value : f32,
    max_value : f32,
    level : i32,
    level_increase : f32,
}

Player :: struct {
    pos : rl.Vector2,
    vel : rl.Vector2,
    radius : f32,
    speed : f32,
    weapon : Weapon,
    ability : ab.Ability,
    ability_cd : ab.Ability_Cooldown,
    health : h.Health,
    h_bar : ui.UI_Progress_Bar,
    v_bar : ui.UI_Progress_Bar,

    loot_bag : Loot_Bag,

    collider : cl.Collider_Circle,
}

update_player :: proc(p: ^Player, dt: f32, level : m.Tiled_Map, check_col : bool){
    p.vel = {0, 0}
    if rl.IsKeyDown(.W) {p.vel.y = -1}
    if rl.IsKeyDown(.S) {p.vel.y = 1}
    if rl.IsKeyDown(.A) {p.vel.x = -1}
    if rl.IsKeyDown(.D) {p.vel.x = 1}

    if rl.Vector2Length(p.vel)> 0.01{
        p.vel = rl.Vector2Normalize(p.vel)
        p.vel *= p.speed
    }

    next_pos := p.pos + p.vel * dt
    if !cl.check_player_wall(next_pos, p.radius, level, check_col){
        p.pos += p.vel * dt
        p.collider.pos = p.pos
    }
}

update_shooting :: proc(p : ^Player, camera : rl.Camera2D, dt : f32) -> (b.Bullet, bool){
    if p.weapon.cooldown > 0{
        p.weapon.cooldown -= dt
    }

    if rl.IsMouseButtonDown(.LEFT) && p.weapon.cooldown <= 0{
        p.weapon.cooldown = p.weapon.fire_rate
        bullet := b.create_bullet(p.pos, camera)
        return bullet, true
    }
    return {}, false
}

draw_player :: proc(p : Player){
    rl.DrawCircleV(p.pos, p.radius, rl.PURPLE)
}

create_player :: proc(level : m.Tiled_Map) -> Player{
    return {
        speed = 400,
        radius = 32,
        weapon = {
            fire_rate = 0.5,
        },
        health = {
          current = 50,
          max = 100,  
        },
        collider = {
            radius = 28,
        },
        loot_bag = {
            max_value = 500,
            level = 1,
            level_increase = 250,
        }
    }
}

increase_value :: proc(bag : ^Loot_Bag, value : f32){
    bag.value += value
    if bag.value >= bag.max_value{
        bag.level += 1
        bag.value -= bag.max_value
        bag.max_value += bag.level_increase
    }
}