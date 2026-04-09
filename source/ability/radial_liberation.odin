package ability

import rl "vendor:raylib"
import bullet "../bullet"
import "../upgrade"
import "core:math"

Radial_Liberation :: struct{
    damage : f32,
    count : f32,
}

cast_radial_liberation :: proc(a : Radial_Liberation, bullets : ^[dynamic]bullet.Bullet, pos : rl.Vector2){
    for i in 0..<a.count{
        angle := f32(i) * (rl.PI * 2.0 / f32(a.count))
        dir := rl.Vector2{
            math.cos(angle),
            math.sin(angle)
        }

        b := bullet.Bullet{
            damage = a.damage,
            pos = pos,
            dir = dir,
            speed = 500,
            radius = 8,
            collider = {
                radius = 8,
            },
            is_active = true
        }
        append(bullets, b)
    }
}