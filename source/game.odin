package game

import rl "vendor:raylib"
import b "bullet"
import e "enemy"
import pl "player"
import m "map"
import pacl "particle"

Game_State :: struct{
    player : pl.Player,
    spawn_player : rl.Vector2,
    camera : rl.Camera2D,
    is_paused : bool,
    play_time : f32,

    player_bullets : [dynamic]b.Bullet,
    enemies : [dynamic]e.Dummy_Enemy,
    particles : [dynamic]pacl.Particle,
    level : m.Tiled_Map,

    helper_activated : bool,
}