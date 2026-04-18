package game

Ability :: union{
    Radial_Liberation, Dash
}

Ability_Cooldown :: struct{
    cooldown : f32,
    timer : f32,
    cast_rate : f32,
}