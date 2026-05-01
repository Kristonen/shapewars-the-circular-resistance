package game

import "core:fmt"
import rl "vendor:raylib"

init_skilltrees :: proc(){
    for type in Skilltree_Bullet_Type{
        create_skill_tree(type, &game.skilltrees)
    }
    for type in Skilltree_Ability_Type{
        create_skill_tree(type, &game.skilltrees)
    }
}

init_shaders :: proc(){
    game.glow.shader = rl.LoadShader(nil, "assets/shaders/glow.glsl")
    game.glow.intensity_loc = rl.GetShaderLocation(game.glow.shader, "intensity")
}