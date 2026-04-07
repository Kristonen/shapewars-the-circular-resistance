package ui

import rl "vendor:raylib"
import ab "../ability"

UI_Cooldown :: struct{
    width : f32,
    height : f32,
    pos : rl.Vector2,
    value : f32,
    max : f32,
    icon : rl.Texture2D,
}