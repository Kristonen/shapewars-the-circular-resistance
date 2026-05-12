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
    w := Weapon{
        fire_rate = 0.5,
        bullet = create_bullet(8, 700, 10),
        amount = 1,
    }
    defer clear(&w.bullet.applied_status)
    return w
}

create_pierce_weapon :: proc() -> Weapon{
    w := Weapon{
        fire_rate = 1,
        bullet = create_bullet(12, 500, 8),
        amount = 1,
    }
    defer clear(&w.bullet.applied_status)
    return w
}

switch_weapon :: proc(){
    delete(game.player.weapon.bullet.applied_status)
    switch game.player.current_weapon{
        case .NormalBullet:
            game.player.weapon = create_normal_weapon()
        case .PierceBullet:
            game.player.weapon = create_pierce_weapon()
            append(&game.player.weapon.bullet.applied_status, create_bleed_status(5, 0.5, 2))
        case .Dash:
        case .RadialLiberation:
    }
}