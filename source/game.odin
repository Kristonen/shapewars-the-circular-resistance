package game

import "core:mem/virtual"
import "core:mem"
import rl "vendor:raylib"
import m "map"
import "loot"
import "ui"

game : Game_State

Create_Hit_Particle :: #type proc(pos : rl.Vector2)

Entity :: union {Player, Enemy}
Unlocked_Type :: enum{Weapon, Ability}
Unlocked_Data_Type :: enum{NormalBullet, PierceBullet, Dash, RadialLiberation}
// Unlocked_Data :: union{Weapon, Ability}
Unlocked :: struct{
    name : string,
    data : Unlocked_Data_Type,
    type : Unlocked_Type,
    unlocked : bool,
}

create_unlockable :: proc(idx : i32, name : string, data : Unlocked_Data_Type, type : Unlocked_Type, unlocked : bool = false){
    game.unlockables[idx].name = name
    game.unlockables[idx].data = data
    game.unlockables[idx].type = type
    game.unlockables[idx].unlocked = unlocked
}

Game_State :: struct{
    player : Player,
    camera : rl.Camera2D,
    unlockables : [12]Unlocked,
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

    skill_points : i32,
    rank : i32,
    current_xp : f32,
    max_xp : f32,
    
    helper_activated : bool,
    map_drawing : bool,
    should_close : bool,

    tooltips : map[string]string,
    tooltip_ptr : any,
    tooltip_pos : rl.Vector2,
    tooltip : ui.UI_ToolTip,
    tooltip_timer : f32,

    skilltrees : map[string]UI_Skill_Tree,
    active_skilltree : Skilltree_Type,

    map_arena : virtual.Arena,
    map_allocator : mem.Allocator,

    skill_arena : virtual.Arena,
    skill_allocator : mem.Allocator,

    all_bullets : [dynamic]Skilltree_Bullet_Type,
    unlocked_bullets : [dynamic]Skilltree_Bullet_Type,

    all_abilities : [dynamic]Skilltree_Ability_Type,
    unlocked_abilities : [dynamic]Skilltree_Ability_Type,

    //Test
    fbo : rl.RenderTexture,
    glow : Glow_Shader,
    // glow_shader : rl.Shader,
    // intensity_loc : i32,
}