package game

import "core:math/rand"
import "core:math"
import rl "vendor:raylib"

Fake_Particle_Gravitiy :: 2.5

Particle_Type :: enum{Normal, Line, Expanding, PlasmaSmoke}

Particle :: struct{
    pos : rl.Vector2,
    entity_pos : rl.Vector2,
    vel: rl.Vector2,
    color : rl.Color,
    life : f32,
    max_life : f32,
    size : f32,
    alive : bool,
    use_grav : bool,
    type : Particle_Type,
}

get_random_unit_vector :: proc() -> rl.Vector2{
    random_fraction := f32(rl.GetRandomValue(0, 1000))
    angle := random_fraction * 2.0 * math.PI
    return {
        math.cos(angle), math.sin(angle)
    }
}

create_hit_particles :: proc(area : rl.Rectangle){
    amount := rl.GetRandomValue(25, 40)
    for _ in 0..<amount{
        angle := f32(rl.GetRandomValue(0, 360)) * (math.PI / 100.0)
        speed := f32(rl.GetRandomValue(20, 150))
        p : Particle = {
            pos = {area.x + area.width/2, area.y + area.height/2},
            vel = {math.cos(angle) * speed, math.sin(angle) * speed},
            color = rl.RED,
            max_life = f32(rl.GetRandomValue(5, 10)) / 10,
            size = f32(rl.GetRandomValue(5, 9)),
            alive = true,
            type = .Normal,
        }
        append(&game.level.particles, p)
    }
}

create_explosion_particles :: proc(area : rl.Rectangle){

    p := Particle{
        pos = {area.x, area.y},
        vel = {0, 0},
        size = 0,
        type = .Expanding,
        max_life = 0.2,
        color = rl.GOLD,
        alive = true,
    }

    append(&game.level.particles, p)

    // for _ in 0..<amount{
    //     angle := f32(rl.GetRandomValue(0, 360)) * (math.PI/100.0)
    //     speed := f32(rl.GetRandomValue(180, 220))
    //     p : Particle = {
    //         pos = {area.x, area.y},
    //         vel = {math.cos(angle) * speed, math.sin(angle) * speed},
    //         color = rl.RED,
    //         max_life = f32(rl.GetRandomValue(10, 15)) / 10,
    //         size = f32(rl.GetRandomValue(5, 8)),
    //         alive = true,
    //         type = .Normal,
    //     }
    //     append(&game.level.particles, p)
    // }

    for _ in 0..<25{
        dir := get_random_unit_vector()
        speed := f32(rl.GetRandomValue(30, 100))
        color := (rl.GetRandomValue(0, 1) == 0) ? rl.RED : rl.PURPLE
        p := Particle{
            pos = {area.x, area.y},
            vel = dir * speed,
            color = color,
            max_life = f32(rl.GetRandomValue(3, 6)) / 10,
            size = 16.0,
            type = .PlasmaSmoke,
            alive = true,
        }
        append(&game.level.particles, p)
    }

    for _ in 0..<50{
        angle := f32(rl.GetRandomValue(0, 360)) * (math.PI/100.0)
        speed := f32(rl.GetRandomValue(400, 700))
        rand := rl.GetRandomValue(1, 3)
        color := rand == 1 ? rl.RED : rand == 2 ? rl.ORANGE : rl.YELLOW
        p : Particle = {
            pos = {area.x, area.y},
            vel = {math.cos(angle) * speed, math.sin(angle) * speed},
            color = color,
            size = 15.0,
            max_life = 0.2,
            type = .Line,
            alive = true,
        }
        append(&game.level.particles, p)
    }
}

create_bleeding_particle :: proc(area : rl.Rectangle){
    for _ in 0..<3{
        x := f32(rl.GetRandomValue(i32(area.x), i32(area.x + area.width)))
        y := f32(rl.GetRandomValue(i32(area.y), i32(area.y + area.height)))
        
        amount := rl.GetRandomValue(5, 10)
        for i in 0..<amount{
            red := u8(rl.GetRandomValue(150, 255))
            speed := f32(rl.GetRandomValue(30, 60))
            angle := f32(rl.GetRandomValue(0, 360)) * (math.PI/100.0)
            p : Particle = {
                pos = {x, y},
                vel = {math.cos(angle) * speed, math.sin(angle) * speed},
                color = {red, 0, 0, 255},
                max_life = f32(rl.GetRandomValue(2, 3))/10,
                size = f32(rl.GetRandomValue(3, 5)),
                alive = true,
                type = .Normal,
            }
            append(&game.level.particles, p)
        }
    }
}

create_destroy_bullet_particle :: proc(area : rl.Rectangle){
    amount := rl.GetRandomValue(10, 20)
    for _ in 0..<amount{
        angle := f32(rl.GetRandomValue(0, 360)) * (math.PI / 100.0)
        speed := f32(rl.GetRandomValue(25, 50))
        p : Particle = {
            pos = {area.x + area.width/2, area.y + area.height/2},
            vel = {math.cos(angle) * speed, math.sin(angle) * speed},
            color = rl.GRAY,
            max_life = f32(rl.GetRandomValue(3, 5)) / 10,
            size = f32(rl.GetRandomValue(2, 5)),
            alive = true,
            type = .Normal,
        }
        append(&game.level.particles, p)
    }
}

create_poison_particle :: proc(area : rl.Rectangle){
    amount := rl.GetRandomValue(5, 10)
    directions := []rl.Vector2{{1,1}, {-1, -1}, {-1, 1}, {1, -1}}
    for i in 0..<4{
        dir := directions[i]
        new_pos : rl.Vector2 = {area.x + area.width/2, area.y + area.height/2} + dir * 20
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
                alive = true,
                type = .Normal,
            }
            append(&game.level.particles, p)
        }
    }
}

create_death_poison_particle :: proc(pos : rl.Vector2){
    amount := rl.GetRandomValue(20, 40)
    for _ in 0..<amount{
        x := f32(rl.GetRandomValue(-250, 250))
        y := f32(rl.GetRandomValue(-300, -200))
        p := Particle{
            pos = pos,
            vel = {x, y},
            max_life = f32(rl.GetRandomValue(3, 6))/10,
            color = {0, 215, 0, 255},
            size = f32(rl.GetRandomValue(3, 9)),
            alive = true,
            use_grav = true,
            type = .Normal,
        }

        append(&game.level.particles, p)
    }

}

create_fire_particle :: proc(area : rl.Rectangle){
    amount := rl.GetRandomValue(30, 50)
    dir := rl.Vector2 {0, -1}
    for _ in 0..<amount{
        red := u8(rl.GetRandomValue(150, 255))
        speed := f32(rl.GetRandomValue(30, 60))
        x := f32(rl.GetRandomValue(-25, 25))
        y := f32(rl.GetRandomValue(-20, 20))
        p : Particle = {
            pos = {area.x + (area.width/2) + x, area.y + (area.height/2) + y},
            vel = dir * speed,
            color = {red, 0, 0, 255},
            max_life = f32(rl.GetRandomValue(5, 8)) / 10,
            size = f32(rl.GetRandomValue(1, 7)),
            alive = true,
            type = .Normal,
        }
        append(&game.level.particles, p)
        smoke_p := p
        smoke_p.pos.y -= 20
        smoke_p.color = {65, 65, 65, 255}
        append(&game.level.particles, smoke_p)
    }
}

create_dash_particle :: proc(pos : rl.Vector2, dir : rl.Vector2){
    amount : i32 = 2
    directions := []rl.Vector2 {{dir.y, -dir.x}, {-dir.y, dir.x}}
    for i in 0..<len(directions){
        dir := directions[i]
        for _ in 0..<amount{
            gray := u8(rl.GetRandomValue(50, 175))
            speed := f32(rl.GetRandomValue(50, 100))
            p := Particle{
                pos = pos,
                vel = dir * speed,
                color = {gray, gray, gray, 255},
                max_life = f32(rl.GetRandomValue(1, 2)),
                size = f32(rl.GetRandomValue(4, 6)),
                alive = true,
                type = .Normal,
            }
            append(&game.level.particles, p)
        }
    }
    for _ in 0..<amount{
        x := pos.x + rand.float32_range(5, 16)
        y := pos.y + rand.float32_range(5, 16)
        p := Particle{
            pos = {x, y},
            color = rl.BROWN,
            max_life = f32(rl.GetRandomValue(2, 4)),
            size = f32(rl.GetRandomValue(2, 5)),
            alive = true,
            type = .Normal,
        }
        append(&game.level.particles, p)
    }
}