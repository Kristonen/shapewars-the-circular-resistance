package game

import "core:math"
import rl "vendor:raylib"

Particle :: struct{
    pos : rl.Vector2,
    entity_pos : rl.Vector2,
    vel: rl.Vector2,
    color : rl.Color,
    life : f32,
    max_life : f32,
    size : f32,
    alive : bool
}

create_hit_particles :: proc(pos : rl.Vector2){
    amount := rl.GetRandomValue(25, 40)
    for _ in 0..<amount{
        angle := f32(rl.GetRandomValue(0, 360)) * (math.PI / 100.0)
        speed := f32(rl.GetRandomValue(20, 150))
        p : Particle = {
            pos = pos,
            vel = {math.cos(angle) * speed, math.sin(angle) * speed},
            color = rl.RED,
            max_life = f32(rl.GetRandomValue(5, 10)) / 10,
            size = f32(rl.GetRandomValue(5, 9)),
            alive = true
        }
        append(&game.current_level.particles, p)
    }
}

create_destroy_bullet_particle :: proc(pos : rl.Vector2){
    amount := rl.GetRandomValue(10, 20)
    for _ in 0..<amount{
        angle := f32(rl.GetRandomValue(0, 360)) * (math.PI / 100.0)
        speed := f32(rl.GetRandomValue(25, 50))
        p : Particle = {
            pos = pos,
            vel = {math.cos(angle) * speed, math.sin(angle) * speed},
            color = rl.GRAY,
            max_life = f32(rl.GetRandomValue(3, 5)) / 10,
            size = f32(rl.GetRandomValue(2, 5)),
            alive = true
        }
        append(&game.current_level.particles, p)
    }
}

create_poison_particle :: proc(pos : rl.Vector2){
    amount := rl.GetRandomValue(5, 10)
    directions := []rl.Vector2{{1,1}, {-1, -1}, {-1, 1}, {1, -1}}
    for i in 0..<4{
        dir := directions[i]
        new_pos := pos + dir * 20
        speed := f32(rl.GetRandomValue(25, 50))
        for _ in 0..<amount{
            green_c : u8 = u8(rl.GetRandomValue(150, 200))
            x := f32(rl.GetRandomValue(-8, 8))
            y : f32
            if x > 0{
                y = f32(rl.GetRandomValue(0, 8))
            } else {
                y = f32(rl.GetRandomValue(-8, 0))
            }
            p : Particle = {
                pos = {new_pos.x + x, new_pos.y + y},
                vel = {-(dir.x * speed), -(dir.y * speed)},
                color = {0, green_c, 0, 255},
                max_life = f32(rl.GetRandomValue(3, 6)) / 10,
                size = f32(rl.GetRandomValue(3, 9)),
                alive = true
            }
            append(&game.current_level.particles, p)
        }
    }
}

create_fire_particle :: proc(pos : rl.Vector2){
    amount := rl.GetRandomValue(30, 50)
    dir := rl.Vector2 {0, -1}
    for _ in 0..<amount{
        red := u8(rl.GetRandomValue(150, 255))
        speed := f32(rl.GetRandomValue(30, 60))
        x := f32(rl.GetRandomValue(-25, 25))
        y := f32(rl.GetRandomValue(-20, 20))
        p : Particle = {
            pos = {pos.x + x, pos.y + y},
            vel = dir * speed,
            color = {red, 0, 0, 255},
            max_life = f32(rl.GetRandomValue(5, 8)) / 10,
            size = f32(rl.GetRandomValue(1, 7)),
            alive = true,
        }
        append(&game.current_level.particles, p)
        smoke_p := p
        smoke_p.pos.y -= 20
        smoke_p.color = {65, 65, 65, 255}
        append(&game.current_level.particles, smoke_p)
    }
}