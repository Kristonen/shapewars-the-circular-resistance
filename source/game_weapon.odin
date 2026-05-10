package game

import rl "vendor:raylib"

Weapon :: struct {
    fire_rate : f32,
    cooldown : f32,
    bullet : Bullet,
    lifesteal : f32,
    amount : f32,
}

create_normal_weapon :: proc() -> Weapon{
    return {
        fire_rate = 0.5,
        bullet = create_bullet(8, 700, 10),
        amount = 1,
    }
}

create_pierce_weapon :: proc() -> Weapon{
    w := Weapon{
        fire_rate = 1,
        bullet = create_bullet(12, 500, 8),
        amount = 1,
    }
    return w
}