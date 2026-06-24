package game

import "core:fmt"
import "core:mem/virtual"
import "core:mem"
import rl "vendor:raylib"
import m "map"
import "ui"

game : Game

Entity :: union {Player, Enemy}
Unlocked_Type :: enum{Weapon, Ability}
Unlocked_Data_Type :: enum{NormalBullet, PierceBullet, Dash, Radial_Liberation, Bomb}
Unlocked :: struct{
    name : string,
    data : Unlocked_Data_Type,
    type : Unlocked_Type,
    unlocked : bool,
    blueprints : i32,
    cost : f32,
}

InGame_State :: enum{
    None, Active
}

create_unlockable :: proc(idx : i32, name : string, data : Unlocked_Data_Type, type : Unlocked_Type, unlocked : bool = false, cost : f32 = 0){
    game.unlockables[idx].name = name
    game.unlockables[idx].data = data
    game.unlockables[idx].type = type
    game.unlockables[idx].unlocked = unlocked
    game.unlockables[idx].cost = cost
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

get_text_for_craftable :: proc(type : Unlocked_Data_Type) -> string{
    unlockable : Unlocked
    for u in game.unlockables{
        if u.data == type{
            unlockable = u
            break
        }
    }
    text := fmt.tprintf("Name: %v\nBlueprints: %i\nCost: %0.0f", type, unlockable.blueprints, unlockable.cost)
    return text
}

get_unlockable :: proc(type : Unlocked_Data_Type) -> (^Unlocked, int){
    unlocked : ^Unlocked
    i : int
    for &u, idx in game.unlockables{
        if u.data != type do continue
        unlocked = &u
        i = idx
        break
    }
    return unlocked, i
}

Game :: struct{
    player : Player,
    camera : rl.Camera2D,
    unlockables : [12]Unlocked,
    shake : f32,

    is_paused : bool,
    play_time : f32,

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
    shards : f32,
    
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
    cd_shader : Cooldown_Shader,
    dissolve : Dissolve_Shader,
    // glow_shader : rl.Shader,
    // intensity_loc : i32,
}

is_in_viewport :: proc(target_rec : rl.Rectangle) -> bool{
    screen_top_left := rl.GetScreenToWorld2D({0, 0}, game.camera)
    screen_bottom_right := rl.GetScreenToWorld2D({f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}, game.camera)
    camera_rec := rl.Rectangle{
        x = screen_top_left.x,
        y = screen_top_left.y,
        width = screen_bottom_right.x - screen_top_left.x,
        height = screen_bottom_right.y - screen_top_left.y,
    }

    return rl.CheckCollisionRecs(camera_rec, target_rec)
}

get_rec_from_circle :: proc(pos : rl.Vector2, radius : f32) -> rl.Rectangle{
    return {
        x = pos.x + radius,
        y = pos.y + radius,
        width = radius * 2,
        height = radius * 2,
    }
}