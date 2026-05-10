package game

import rl "vendor:raylib"

Dash :: struct{
    ability_cd : Ability_Cooldown,
    dir : rl.Vector2,
    timer : f32,
    speed : f32,
}