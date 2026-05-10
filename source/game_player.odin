package game

import rl "vendor:raylib"
import cl "collider"
import "ui"

Ghost_Time :: 0.025

Loot_Bag :: struct{
    value : f32,
    max_value : f32,
    level : i32,
    level_increase : f32,
    mul : f32,
}

Ghost_Image :: struct{
    pos : rl.Vector2,
    life : f32,
}

Player :: struct {
    pos : rl.Vector2,
    vel : rl.Vector2,
    radius : f32,
    speed : f32,

    weapon : Weapon,

    ability : Ability,
    target_ability : Upgrade_Target,

    health : Health,
    h_bar : ui.UI_Progress_Bar,
    v_bar : ui.UI_Progress_Bar,

    statuses : [dynamic]Status_Effect,

    loot_bag : Loot_Bag,
    increase_value : proc(b : ^Loot_Bag, value : f32) `json:"-"`, 

    hurt_collider : cl.Collider_Circle,
    collector : cl.Collider_Circle,
    physics_collider : cl.Collider_Circle,

    ignore_input : bool,

    ghosts : [50]Ghost_Image,
    ghost_timer : f32,
}

create_player :: proc() -> Player{
    p := Player{
        speed = 400,
        radius = 32,
        weapon = create_normal_weapon(),
        health = {
          current = 100,
          max = 100, 
          take_dmg = take_damage,
          heal = heal,
        },
        loot_bag = {
            max_value = 50,
            level = 1,
            level_increase = 50,
            mul = 1,
        },
        increase_value = increase_value,
    }
    p.physics_collider = {
        radius = p.radius,
        pos = p.pos
    }
    p.collector = {
        radius = p.radius * 0.5,
        pos = p.pos,
    }
    p.hurt_collider = {
        radius = p.radius * 0.75,
        pos = p.pos
    }
    return p
}

increase_value :: proc(bag : ^Loot_Bag, value : f32){
    bag.value += value * bag.mul
    if bag.value >= bag.max_value{
        bag.level += 1
        bag.value -= bag.max_value
        bag.max_value += bag.level_increase
        game.level.power_level_up = true
    }
}

apply_lifesteal :: proc(p : ^Player, dmg : f32){
    if p.weapon.lifesteal == 0 do return

    add_h := p.weapon.lifesteal * dmg
    p.health->heal(add_h)
}

get_upgrade_target :: proc() {
    switch a in game.player.ability.data{
        case Radial_Liberation_Data:
            game.player.target_ability = .Radial_Liberation
        case Dash_Data:
            game.player.target_ability = .Dash
    }
}

get_ability_cd :: proc() -> ^Ability_Cooldown{
    return &game.player.ability.cd
}