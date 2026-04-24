package game

import rl "vendor:raylib"
import m "map"
import "loot"
import "ui"

game : Game_State

Create_Hit_Particle :: #type proc(pos : rl.Vector2)

Entity :: union {Player, Enemy}

Game_State :: struct{
    player : Player,
    spawn_player : rl.Vector2,
    camera : rl.Camera2D,
    shake : f32,
    is_paused : bool,
    play_time : f32,

    create_hit_particle : Create_Hit_Particle,

    menu : ui.UI_Menu,
    current_menu : ui.Menu_Type,
    last_menu : ui.Menu_Type,

    level_data : [dynamic]Level_Data,
    current_level : Level_Data,

    helper_activated : bool,
    map_drawing : bool,
    should_close : bool,

    tooltips : map[string]string,
    tooltip_ptr : any,
    tooltip_pos : rl.Vector2,
    tooltip : ui.UI_ToolTip,
    tooltip_timer : f32
}

Level_Data :: struct{
    spawner : [dynamic]Spawner,
    enemies : [dynamic]Enemy,
    enemy_fragments : [dynamic]Enemy_Death_Fragment,
    enemy_bullets : [dynamic]Bullet,

    particles : [dynamic]Particle,

    npcs : [dynamic]NPC,

    player_bullets : [dynamic]Bullet,

    loot : [dynamic]loot.Shape_Shard,

    power_level_up : bool,
    upgrade_menu : UI_Upgrade_Menu,
    upgrade_pool : [dynamic]Upgrade,
    available_upgrades : [dynamic]Upgrade,

    ui_elements : [dynamic]ui.UI_Element,
    level_visual : m.Tiled_Map,
}

create_start_level :: proc() -> Level_Data{
    level : Level_Data
    return level
}