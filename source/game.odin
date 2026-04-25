package game

import "core:mem"
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

    levels : [dynamic]Level_Type,
    current_level : Level_Type,
    level : Level_Data,
    

    helper_activated : bool,
    map_drawing : bool,
    should_close : bool,

    tooltips : map[string]string,
    tooltip_ptr : any,
    tooltip_pos : rl.Vector2,
    tooltip : ui.UI_ToolTip,
    tooltip_timer : f32,

    map_allocator : mem.Allocator
}