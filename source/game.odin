package game

import rl "vendor:raylib"

Game_State :: struct{
    player : Player,
    spawn_player : rl.Vector2,
    camera : rl.Camera2D,
    is_paused : bool,
    play_time : f32,

    player_bullets : [dynamic]Bullet,
    enemies : [dynamic]Dummy_Enemy,
    particles : [dynamic]Particle,
    level : Tiled_Map,

    helper_activated : bool,
}