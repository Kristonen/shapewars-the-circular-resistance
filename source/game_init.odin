package game

import "core:fmt"
import rl "vendor:raylib"

init_skilltrees :: proc(){
    for type in Unlocked_Data_Type{
        create_skill_tree(type, &game.skilltrees)
    }
}

init_shaders :: proc(){
    game.glow.shader = rl.LoadShader(nil, "assets/shaders/glow.glsl")
    game.glow.intensity_loc = rl.GetShaderLocation(game.glow.shader, "intensity")

    game.cd_shader.shader = rl.LoadShader(nil, "assets/shaders/cooldown.glsl")
    game.cd_shader.progress_loc = rl.GetShaderLocation(game.cd_shader.shader, "cooldownProgress")

    game.dissolve.shader = rl.LoadShader(nil, "assets/shaders/test.glsl")
    game.dissolve.time_loc = rl.GetShaderLocation(game.dissolve.shader, "time")
    game.dissolve.radius_loc = rl.GetShaderLocation(game.dissolve.shader, "radius")
    game.dissolve.center_loc = rl.GetShaderLocation(game.dissolve.shader, "centerPos")
}

init_unlockables :: proc(){
    //Bullet
    create_unlockable(0, "Normal Bullet", .NormalBullet, .Weapon, true)
    create_unlockable(1, "Bloody Pain", .PierceBullet, .Weapon, true)
    create_unlockable(2, "", .NormalBullet, .Weapon, cost = 5000)
    create_unlockable(3, "", .NormalBullet, .Weapon)
    create_unlockable(4, "", .NormalBullet, .Weapon)
    create_unlockable(5, "", .NormalBullet, .Weapon)
    //Ability
    create_unlockable(6, "Dash", .Dash, .Ability, true)
    create_unlockable(7, "Radial Liberation", .Radial_Liberation, .Ability, true)
    create_unlockable(8, "Bomb", .Bomb, .Ability, cost = 10)
    create_unlockable(9, "", .NormalBullet, .Ability)
    create_unlockable(10, "", .NormalBullet, .Ability)
    create_unlockable(11, "", .NormalBullet, .Ability)
}