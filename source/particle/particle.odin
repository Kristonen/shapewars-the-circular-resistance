package particle

import "core:math"
import rl "vendor:raylib"

Particle :: struct{
    pos : rl.Vector2,
    vel: rl.Vector2,
    color : rl.Color,
    life : f32,
    max_life : f32,
    size : f32,
    alive : bool
}

update_particle :: proc(p : ^Particle, dt : f32){
    p.life += dt
    p.pos += p.vel * dt

    if p.life >= p.max_life{
        p.alive = false
    }
}

draw_particles :: proc(p : Particle){
    alpha := 1.0 - (p.life / p.max_life)
    color := p.color
    color.a = u8(alpha*255)

    rl.DrawCircleV(p.pos, p.size/2, color)
}

create_hit_particles :: proc(particles : ^[dynamic]Particle, pos : rl.Vector2){
    amount := rl.GetRandomValue(25, 40)
    for _ in 0..<amount{
        angle := f32(rl.GetRandomValue(0, 360)) * (math.PI / 100.0)
        speed := f32(rl.GetRandomValue(20, 150))
        p : Particle = {
            pos = pos,
            vel = {math.cos(angle) * speed, math.sin(angle) * speed},
            color = rl.RED,
            max_life = f32(rl.GetRandomValue(5, 10)) / 10,
            size = f32(rl.GetRandomValue(2, 5)),
            alive = true
        }
        append(particles, p)
    }
}

create_destroy_bullet_particle :: proc(particles : ^[dynamic]Particle, pos : rl.Vector2){
    amount := rl.GetRandomValue(10, 20)
    for _ in 0..<amount{
        angle := f32(rl.GetRandomValue(0, 360)) * (math.PI / 100.0)
        speed := f32(rl.GetRandomValue(25, 50))
        p : Particle = {
            pos = pos,
            vel = {math.cos(angle) * speed, math.sin(angle) * speed},
            color = rl.GRAY,
            max_life = f32(rl.GetRandomValue(3, 5)) / 10,
            life = 0,
            size = f32(rl.GetRandomValue(2, 5)),
            alive = true
        }
        append(particles, p)
    }
}