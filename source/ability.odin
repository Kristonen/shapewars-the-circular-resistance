package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Ability_Data :: union {
    Radial_Liberation_Data, Dash_Data, Bomb_Data
}

Ability_Indicator_Update :: #type proc(dt : f32)
Ability_Update :: #type proc(dt : f32)
Ability_Activate :: #type proc(dt : f32)
Ability_Finish :: #type proc(dt : f32)
Ability_Draw :: #type proc()

Ability_Projectile_Draw :: #type proc(p : Ability_Projectile)

Ability :: struct{
    cd : Ability_Cooldown,
    indicator_active : bool,
    activated : bool,
    active : bool,
    casting : bool,
    indicator : Ability_Indicator_Update,
    activate : Ability_Activate,
    update : Ability_Update,
    finish : Ability_Finish,
    data : Ability_Data,
    draw : Ability_Draw,
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
    data : Enemy_Ability_Data,
    draw : Ability_Projectile_Draw,
}

no_indicator_update :: proc(dt : f32){
    game.player.ability.activated = true
}
no_activate :: proc(dt : f32){
    game.player.ability.active = true
    game.player.ability.activated = false
    game.player.ability.indicator_active = false
}
no_update :: proc(dt : f32){}
no_finish :: proc(dt : f32){}
no_draw :: proc(){}

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