package game

import rl "vendor:raylib"

Game_State :: struct{
    player : Player,
    camera : rl.Camera2D,
    is_paused : bool,
    play_time : f32,

    player_bullets : [dynamic]Bullet,
    enemies : [dynamic]Dummy_Enemy,

    helper_activated : bool,
}