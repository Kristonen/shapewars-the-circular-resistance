package game

import "core:mem/virtual"
import "core:mem"
import rl "vendor:raylib"
import m "map"
import "ui"

game : Game_State

Create_Hit_Particle :: #type proc(area : rl.Rectangle)

Entity :: union {Player, Enemy}
Unlocked_Type :: enum{Weapon, Ability}
Unlocked_Data_Type :: enum{NormalBullet, PierceBullet, Dash, Radial_Liberation, Bomb}
Unlocked :: struct{
    name : string,
    data : Unlocked_Data_Type,
    type : Unlocked_Type,
    unlocked : bool,
    blueprints : i32,
}

create_unlockable :: proc(idx : i32, name : string, data : Unlocked_Data_Type, type : Unlocked_Type, unlocked : bool = false){
    game.unlockables[idx].name = name
    game.unlockables[idx].data = data
    game.unlockables[idx].type = type
    game.unlockables[idx].unlocked = unlocked
}

get_text_for_unlocked :: proc(type : Unlocked_Data_Type) -> string{
    text := ""
    switch type{
        case .NormalBullet:
            text = "Damage : 10\nFire rate : 0.5\nSpeed : 700"
        case .PierceBullet:
            text = "Damage : 8\nFire rate : 1.0\nSpeed : 500\nThis weapon will make the enemy bleed."
        case .Dash:
            text = "Make a big movment to the position, where you are moving."
        case .Radial_Liberation:
            text = "Create a wave of 8 bullets around the player.\nDamage : 5 (per bullet)"
        case .Bomb:
            text = "Throw a bomb that makes a lot of damage in a area."
    }
    return text
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
    active_skilltree : Unlocked_Data_Type,

    map_arena : virtual.Arena,
    map_allocator : mem.Allocator,

    skill_arena : virtual.Arena,
    skill_allocator : mem.Allocator,

    //Test
    fbo : rl.RenderTexture,
    glow : Glow_Shader,
    // glow_shader : rl.Shader,
    // intensity_loc : i32,
}