package game

import "core:fmt"
import rl "vendor:raylib"
import ab "ability"
import cl "collider"
import b "bullet"
import "ui"
import "upgrade"

Weapon :: struct {
    fire_rate : f32,
    cooldown : f32,
    bullet : b.Bullet,
    lifesteal : f32,
}

Loot_Bag :: struct{
    value : f32,
    max_value : f32,
    level : i32,
    level_increase : f32,
}

Player :: struct {
    pos : rl.Vector2,
    vel : rl.Vector2,
    radius : f32,
    speed : f32,
    weapon : Weapon,
    ability : ab.Ability,
    ability_cd : ab.Ability_Cooldown,
    target_ability : upgrade.Upgrade_Target,
    health : Health,
    h_bar : ui.UI_Progress_Bar,
    v_bar : ui.UI_Progress_Bar,

    // bullet : b.Bullet,

    loot_bag : Loot_Bag,
    increase_value : proc(b : ^Loot_Bag, value : f32) -> bool,

    collider : cl.Collider_Circle,
}

create_player :: proc() -> Player{
    return {
        speed = 400,
        radius = 32,
        weapon = {
            fire_rate = 0.5,
            bullet = b.create_bullet(),
        },
        health = {
          current = 50,
          max = 100, 
          take_dmg = take_damage,
        },
        collider = {
            radius = 28,
        },
        loot_bag = {
            max_value = 50,
            level = 1,
            level_increase = 50,
        },
        increase_value = increase_value,
    }
}

increase_value :: proc(bag : ^Loot_Bag, value : f32) -> bool{
    bag.value += value
    if bag.value >= bag.max_value{
        bag.level += 1
        bag.value -= bag.max_value
        bag.max_value += bag.level_increase
        return true
    }
    return false
}

apply_lifesteal :: proc(p : ^Player, dmg : f32){
    if p.weapon.lifesteal == 0 do return

    add_h := p.weapon.lifesteal * dmg
    p.health.current += add_h
}

get_upgrade_target :: proc(p : ^Player) {
    switch a in p.ability{
        case ab.Radial_Liberation:
            p.target_ability = .Radial_Liberation
        case ab.Dash:
            p.target_ability = .Dash
    }
}