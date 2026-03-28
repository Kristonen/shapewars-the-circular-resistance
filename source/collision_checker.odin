package game

import rl "vendor:raylib"

check_bullet_enemy :: proc(b : Bullet, e : Dummy_Enemy) -> (bool){
    enemy_rectangle := rl.Rectangle{
        x = e.pos.x,
        y = e.pos.y,
        width = e.width,
        height = e.height,
    }

    if rl.CheckCollisionCircleRec(b.pos, b.radius, enemy_rectangle){
        return true
    }

    return false
}