package ui

import rl "vendor:raylib"
import ab "../ability"

UI_Cooldown :: struct{
    width : f32,
    height : f32,
    pos : rl.Vector2,
    icon : rl.Texture2D,
}

draw_cooldown :: proc(e : UI_Cooldown, cd : ab.Ability_Cooldown){
    scale := e.width / f32(e.icon.width)
    // rl.DrawTextureV(e.icon, e.pos, rl.WHITE)
    rl.DrawTextureEx(e.icon, e.pos, 0, scale, rl.WHITE)
    // rl.DrawRectangleV(cd_e.pos, {cd_e.width, cd_e.height}, rl.BLACK)
    color : rl.Color = {255, 255, 255, 75}
    height := e.height * (cd.timer / cd.cooldown)
    rl.DrawRectangleV(e.pos, {e.width, height}, color)

    
}