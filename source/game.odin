package game

import rl "vendor:raylib"
import b "bullet"
import m "map"
import pacl "particle"
import "loot"
import "ui"
import "upgrade"

Create_Hit_Particle :: #type proc(p : ^[dynamic]pacl.Particle, pos : rl.Vector2)

Game_State :: struct{
    player : Player,
    spawn_player : rl.Vector2,
    camera : rl.Camera2D,
    shake : f32,
    is_paused : bool,
    play_time : f32,

    player_bullets : [dynamic]b.Bullet,

    enemies : [dynamic]Dummy_Enemy,
    enemy_fragments : [dynamic]Enemy_Death_Fragment,
    spawner : [dynamic]Spawner,

    create_hit_particle : Create_Hit_Particle,
    particles : [dynamic]pacl.Particle,


    ui_elements : [dynamic]ui.UI_Element,
    loot : [dynamic]loot.Shape_Shard,

    menu : ui.UI_Menu,
    current_menu : ui.Menu_Type,
    last_menu : ui.Menu_Type,
    level : m.Tiled_Map,

    level_up : bool,
    upgrade_menu : upgrade.UI_Upgrade_Menu,
    upgrade_pool : [dynamic]upgrade.Upgrade,
    available_upgrades : [dynamic]upgrade.Upgrade,


    helper_activated : bool,
    map_drawing : bool,
    should_close : bool,
}