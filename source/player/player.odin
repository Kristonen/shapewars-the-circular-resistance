package player

import "core:fmt"
import rl "vendor:raylib"
import ab "../ability"
import b "../bullet"
import cl "../collider"
import m "../map"

Weapon :: struct {
    fire_rate : f32,
    cooldown : f32,
}

Player :: struct {
    pos : rl.Vector2,
    vel : rl.Vector2,
    radius : f32,
    speed : f32,
    weapon : Weapon,
    ability : ab.Ability,
}

update_player :: proc(p: ^Player, dt: f32, level : m.Tiled_Map){
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
    if !cl.check_player_wall(next_pos, p.radius, level){
        p.pos += p.vel * dt
    }
}

update_shooting :: proc(p : ^Player, camera : rl.Camera2D, dt : f32) -> (b.Bullet, bool){
    if p.weapon.cooldown > 0{
        p.weapon.cooldown -= dt
    }

    if rl.IsMouseButtonDown(.LEFT) && p.weapon.cooldown <= 0{
        p.weapon.cooldown = p.weapon.fire_rate
        mouse_pos := rl.GetMousePosition()
        world_mouse := rl.GetScreenToWorld2D(mouse_pos, camera)
        bullet := b.Bullet{
            damage = 10,
            pos = p.pos,
            speed = 500,
            radius = 8,
            dir = rl.Vector2Normalize(world_mouse - p.pos),
            collider = {
                radius = 2,
            }
        }
        return bullet, true
    }
    return {}, false
}

draw_player :: proc(p : Player){
    rl.DrawCircleV(p.pos, p.radius, rl.PURPLE)
}

give_player_spawn_pos :: proc(level : m.Tiled_Map, p : ^Player){

    for layer in level.layers{
        if layer.type == "objectgroup" && layer.name == "SpawnPlayer"{
            object := layer.objects[0]
            pos_x := f32(object.x + object.width/2)
            pos_y := f32(object.y + object.height/2)
            p.pos = {pos_x, pos_y}
            break
        }
    }
}