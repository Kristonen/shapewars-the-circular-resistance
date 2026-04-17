package game

import "core:fmt"
import rl "vendor:raylib"
import "ui"
import "bullet"
import "particle"
import "upgrade"

check_player_wall :: proc(pos_player : rl.Vector2, radius : f32, g : Game_State) -> bool{
    if !g.map_drawing{
        return false
    }
    for layer in g.current_level.level_visual.layers{
        if layer.name == "Walls"{
            for obj in layer.objects{
                wall_rect := rl.Rectangle{
                    x = obj.x,
                    y = obj.y,
                    width = obj.width,
                    height = obj.height,
                }
                if rl.CheckCollisionCircleRec(pos_player, radius, wall_rect){
                    return true
                }
            }
        }
    }
    return false
}

check_bullet :: proc(g : ^Game_State){
    for &b, idx in g.current_level.player_bullets{
        check_bullet_enemy(g, &b)
        check_bullet_wall(g, &b)
    }
}

check_bullet_enemy :: proc(g : ^Game_State, b : ^bullet.Bullet){
    for &e in g.current_level.enemies{
        e_rect := rl.Rectangle{x = e.pos.x, y = e.pos.y, width = e.width, height = e.height}
        if rl.CheckCollisionCircleRec(b.pos, b.radius, e_rect){
            e.on_hit(g, &e, b.damage)
            b.is_active = false
            b.pos = {-10000, -10000}
            if b.can_lifesteal{
                apply_lifesteal(&g.player, b.damage)
            }
        }
    }
}

check_bullet_player :: proc(g : ^Game_State){
    for &b in g.current_level.enemy_bullets{
        c_player := g.player.collider
        c_bullet := b.collider
        if rl.CheckCollisionCircles(c_player.pos, c_player.radius, c_bullet.pos, c_bullet.radius){
            g.player.health->take_dmg(5)
            g.player.health.invincible_timer = 2
            b.pos = {-10000, -10000}
            b.is_active = false
        }
    }
}

check_enemy_player :: proc(g : ^Game_State){
    for &e in g.current_level.enemies{
        e_rect := rl.Rectangle{x = e.pos.x, y = e.pos.y, width = e.width, height = e.height}
        if rl.CheckCollisionCircleRec(g.player.collider.pos, g.player.collider.radius, e_rect) && g.player.health.invincible_timer <= 0{
            g.player.health.take_dmg(&g.player.health, 10)
            g.player.health.invincible_timer = 2
        }
    }
}

check_bullet_wall :: proc(g : ^Game_State, b : ^bullet.Bullet){
    for layer in g.current_level.level_visual.layers{
        if layer.name != "Walls" do continue
        for obj in layer.objects{
            rect := rl.Rectangle{
                x = obj.x, y = obj.y,
                width = obj.width, height = obj.height,
            }

            if rl.CheckCollisionCircleRec(b.pos, b.radius, rect){
                b.is_active = false
                particle.create_destroy_bullet_particle(&g.current_level.particles, b.pos)
            }
        }
    }
}

check_collisions_detection_loot :: proc(g : ^Game_State){
    for &l in g.current_level.loot{
        if l.is_following || !l.is_active do continue

        if rl.CheckCollisionCircles(l.detection.pos, l.detection.radius, g.player.collider.pos, g.player.radius){
            l.is_following = true
        }
    }
}

check_collisions_pickup_loot :: proc(g : ^Game_State){
    for &l, idx in g.current_level.loot{
        if !l.is_active do continue

        if rl.CheckCollisionCircles(l.pickup.pos, l.pickup.radius, g.player.collider.pos, g.player.collider.radius){
            g.current_level.power_level_up = g.player.increase_value(&g.player.loot_bag, l.value)
            if g.current_level.power_level_up{
                level_up_spawner_update(g)
                upgrade.create_upgrade_menu(&g.current_level.upgrade_menu, g.current_level.available_upgrades, g.player.target_ability)
            }
            unordered_remove(&g.current_level.loot, idx)
        }
    }
}

check_collision_upgrade_slot :: proc(g : ^Game_State){
    mouse_pos := rl.GetMousePosition()
    if !g.current_level.upgrade_menu.is_active && rl.IsMouseButtonReleased(.LEFT){
        g.current_level.upgrade_menu.is_active = true
        return
    }
    for &slot in g.current_level.upgrade_menu.upgrades{
        if rl.CheckCollisionPointRec(mouse_pos, slot.rect){
            slot.state = .Focused
            if rl.IsMouseButtonReleased(.LEFT) && g.current_level.upgrade_menu.is_active{
                slot.state = .Selected
            }
        } else{
            slot.state = .None
        }
    }
}

check_collision_menu :: proc(g : ^Game_State){
    for &element in g.menu.elements{
        switch &e in element{
            case ui.UI_Cooldown:
            case ui.UI_Button:
                check_collision_button(&e)
            case ui.UI_Menu:
            case ui.UI_Progress_Bar:
            case ui.UI_Label:
            case ui.UI_Slider:
                check_collision_slider(&e)
        }
    }
}

check_collision_button :: proc(b : ^ui.UI_Button){
    mouse_pos := rl.GetMousePosition()
    rect := rl.Rectangle{
        x = b.pos.x,
        y = b.pos.y,
        width = b.width,
        height = b.height,
    }

    if rl.CheckCollisionPointRec(mouse_pos, rect){
        b.state = .Focus
        if rl.IsMouseButtonDown(.LEFT){
            b.state = .Pressing
        }
        if rl.IsMouseButtonReleased(.LEFT){
            b.state = .Pressed
        }
    } else{
        b.state = .None
    }
}

check_collision_slider :: proc(s : ^ui.UI_Slider){
    mouse_pos := rl.GetMousePosition()
    if rl.CheckCollisionPointRec(mouse_pos, s.slider) && rl.IsMouseButtonDown(.LEFT){
        s.state = .Active
    }
    if s.state == .Active && rl.IsMouseButtonReleased(.LEFT){
        s.state = .None
    }
    //TODO mouse click on the line
}