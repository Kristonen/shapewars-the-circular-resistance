package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Ability_Data :: union {
    Radial_Liberation_Data, Dash_Data, Bomb_Data, Reinforcment_Data
}

Ability_State :: enum{
    None, Using, Charging, Activated, Executing, Finished
}

Ability_Owner :: enum {Player, Enemy}

Ability_Indicator_Update :: #type proc(a : ^Ability, dt : f32)
Ability_Update :: #type proc(a : ^Ability, dt : f32)
Ability_Activate :: #type proc(a : ^Ability, dt : f32)
Ability_Finish :: #type proc(a : ^Ability, dt : f32)
Ability_Draw :: #type proc(a : Ability)
Cast_Draw :: #type proc(pos : rl.Vector2)

Ability_Projectile_Draw :: #type proc(p : Ability_Projectile)

Ability :: struct{
    //Cooldown for the Ability
    cooldown_timer : Ability_Cooldown,
    //Timer for how long it takes to cast the ability
    cast_timer : Ability_Cooldown,

    cast_visualizer : Casting_Visualizer,

    is_available : bool,

    indicator : Ability_Indicator_Update,
    activate : Ability_Activate,
    update : Ability_Update,
    finish : Ability_Finish,
    draw : Ability_Draw,

    data : Ability_Data,

    state : Ability_State,
}

Casting_Visualizer :: struct{
    tick : f32,
    current_tick : f32,
    draw : Cast_Draw,
    can_show : bool,
}

Ability_Cooldown :: struct{
    cooldown : f32,
    timer : f32,
    cast_rate : f32,
}

Indicator :: union{
    AoE_Indicator, Line_Indicator
}

AoE_Indicator :: struct{
    pos : rl.Vector2,
    radius : f32,
}

Line_Indicator :: struct{
    pos : rl.Vector2,
    length : f32,
}

Ability_Projectile_Data :: union{
    Ability_Projectile_Bombardment,
}

Ability_Projectile_Bombardment :: struct{
    radius : f32,
}

Ability_Projectile :: struct{
    rec : rl.Rectangle,
    speed : f32,
    dir : rl.Vector2,
    target_pos : rl.Vector2,
    draw : Ability_Projectile_Draw,
}

no_indicator_update :: proc(a : ^Ability, dt : f32){
    a.state = .Charging
}
no_activate :: proc(a : ^Ability, dt : f32){
    a.state = .Executing
}
no_update :: proc(a : ^Ability, dt : f32){
    a.state = .Finished
}
no_finish :: proc(a : ^Ability, dt : f32){}
no_draw :: proc(a : Ability){}
no_casting_draw :: proc(pos : rl.Vector2){}

switch_ability :: proc(){
    switch game.player.current_ability{
        case .NormalBullet:
        case .PierceBullet:
        case .Radial_Liberation:
            game.player.ability = create_standard_radial_liberation()
        case .Dash:
            game.player.ability = create_standard_dash()
        case .Bomb:
            game.player.ability = create_standard_bomb()
    }
    apply_skilltree(game.player.current_ability)
}