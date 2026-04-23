package collider

import rl "vendor:raylib"

Collider :: union{
    Collider_Circle,
    Collider_Rectangle,
}

Collider_Rectangle :: struct {
    rec : rl.Rectangle,
    // pos : rl.Vector2,
    // width : f32,
    // height : f32,
}

Collider_Circle :: struct{
    pos : rl.Vector2,
    radius : f32,
}