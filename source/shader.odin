package game

import rl "vendor:raylib"

GLOW_PULSE_SPEED :: 3.5
MIN_GLOW :: 1.5
GLOW_AMPLITUDE :: 0.5

Glow_Shader :: struct{
    shader : rl.Shader,
    intensity_loc : i32,
}

Cooldown_Shader :: struct{
    shader : rl.Shader,
    progress_loc : i32,
}