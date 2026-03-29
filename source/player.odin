package game

import "core:fmt"
import rl "vendor:raylib"

Bullet :: struct {
    pos : rl.Vector2,
    dir : rl.Vector2,
    vel : rl.Vector2,
    speed : f32,
    radius : f32,
    collider : Collider
}

Weapon :: struct {
    fire_rate : f32,
    cooldown : f32,
}

Collider :: struct {
    type : ColliderType,
    width : f32,
    height : f32,
    radius : f32,
}

Player :: struct {
    pos : rl.Vector2,
    vel : rl.Vector2,
    radius : f32,
    speed : f32,
    weapon : Weapon,
}

update_player :: proc(p: ^Player, dt: f32){
    p.vel = {0, 0}
    if rl.IsKeyDown(.W) {p.vel.y = -1}
    if rl.IsKeyDown(.S) {p.vel.y = 1}
    if rl.IsKeyDown(.A) {p.vel.x = -1}
    if rl.IsKeyDown(.D) {p.vel.x = 1}

    if rl.Vector2Length(p.vel)> 0.01{
        p.vel = rl.Vector2Normalize(p.vel)
        p.vel *= p.speed
    }
    p.pos += p.vel * dt
}

update_shooting :: proc(p : ^Player, camera : rl.Camera2D, dt : f32) -> (Bullet, bool){
    if p.weapon.cooldown > 0{
        p.weapon.cooldown -= dt
    }

    if rl.IsMouseButtonDown(.LEFT) && p.weapon.cooldown <= 0{
        p.weapon.cooldown = p.weapon.fire_rate
        mouse_pos := rl.GetMousePosition()
        world_mouse := rl.GetScreenToWorld2D(mouse_pos, camera)
        bullet := Bullet{
            pos = p.pos,
            speed = 500,
            radius = 8,
            dir = rl.Vector2Normalize(world_mouse - p.pos),
            collider = {
                type = .Circle,
                radius = 2,
            }
        }
        return bullet, true
    }
    return {}, false
}

update_bullet :: proc(b : ^Bullet, dt : f32){
    b.vel = b.dir * b.speed
    b.pos += b.vel * dt
}

draw_player :: proc(p : Player){
    rl.DrawCircleV(p.pos, p.radius, rl.PURPLE)
}

draw_bullet :: proc(b : Bullet){
    rl.DrawCircleV(b.pos, b.radius, rl.RED)
}

draw_collider :: proc(pos : rl.Vector2, c : Collider){
    if c.type == .Circle{
        rl.DrawCircleV(pos, c.radius, rl.GREEN)
    }
    if c.type == .Rec{
        rl.DrawRectangleV(pos, {c.width, c.height}, rl.GREEN)
    }
}

give_player_spawn_pos :: proc(g : ^Game_State){

    for layer in g.level.layers{
        if layer.type == "objectgroup" && layer.name == "SpawnPlayer"{
            object := layer.objects[0]
            pos_x := f32(object.x + object.width/2)
            pos_y := f32(object.y + object.height/2)
            g.player.pos = {pos_x, pos_y}
            break
        }
    }
}