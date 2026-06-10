package game

import rl "vendor:raylib"

Shoot_Sound :: "assets/audio/standard_shoot.wav"

Weapon :: struct {
    fire_rate : f32,
    cooldown : f32,
    bullet : Bullet,
    lifesteal : f32,
    amount : f32,
    shoot_sound : rl.Sound,
}

create_weapon :: proc(){
    rl.UnloadSound(game.player.weapon.shoot_sound)
    clear(&game.player.weapon.bullet.applied_status)
    if game.player.current_weapon == .NormalBullet{
        game.player.weapon.fire_rate = 0.5
        game.player.weapon.bullet = create_bullet(8, 700, 10)
    } else if game.player.current_weapon == .PierceBullet{
        game.player.weapon.fire_rate = 1
        game.player.weapon.bullet = create_bullet(12, 500, 8)
        append(&game.player.weapon.bullet.applied_status, create_bleed_status(5, 0.5, 2))
    }
    game.player.weapon.amount = 1
    game.player.weapon.shoot_sound = rl.LoadSound(Shoot_Sound)
    rl.SetSoundVolume(game.player.weapon.shoot_sound, 0.30)
}

switch_weapon :: proc(){
    delete(game.player.weapon.bullet.applied_status)
    create_weapon()
    apply_skilltree(game.player.current_weapon)
}