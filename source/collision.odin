package game

import "core:fmt"
import rl "vendor:raylib"
import "ui"
import "handler"

check_player_wall :: proc(pos_player : rl.Vector2, radius : f32) -> bool{
    if !game.map_drawing{
        return false
    }
    for layer in game.current_level.level_visual.layers{
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

check_bullet :: proc(){
    for &b, idx in game.current_level.player_bullets{
        check_bullet_enemy(&b)
        check_bullet_wall(&b)
    }
}

check_bullet_enemy :: proc(b : ^Bullet){
    for &e in game.current_level.enemies{
        if rl.CheckCollisionCircleRec(b.collider.pos, b.collider.radius, e.rec){

            if !check_if_enemy_already_hitted(&e, b^){
                e.on_hit(&e, b.damage)
                add_bullet_status_to_hitted_enemy(b, &e)
                if b.can_lifesteal{
                    apply_lifesteal(&game.player, b.damage)
                }
            }

            if !b.can_pierce{
                b.is_active = false
                b.pos = {-10000, -10000}
            } else{
                append(&b.hitted_enemies, &e)
            }
        }
    }
}

add_bullet_status_to_hitted_enemy :: proc(b : ^Bullet, e : ^Enemy){
    for s in b.applied_status{

        if idx := check_if_entity_already_got_status(e.statuses, s); idx == -1{
            append(&e.statuses, s)
        } else {
            e.statuses[idx] = s
        }
    }
}

check_if_entity_already_got_status :: proc(s_array : [dynamic]Status_Effect, s : Status_Effect) -> i32{
    for e_s, idx in s_array{
        if e_s.type == s.type do return i32(idx)
    }
    return -1
}

check_if_enemy_already_hitted :: proc(e : ^Enemy, b : Bullet) -> bool{
    for &hitted_enemy in b.hitted_enemies{
        if hitted_enemy == e{
            return true
        }
    }
    return false
}

check_bullet_player :: proc(){
    for &b in game.current_level.enemy_bullets{
        c_player := game.player.hurt_collider
        c_bullet := b.collider
        if rl.CheckCollisionCircles(c_player.pos, c_player.radius, c_bullet.pos, c_bullet.radius){
            game.player.health->take_dmg(5)
            game.player.health.invincible_timer = 2
            b.pos = {-10000, -10000}
            b.is_active = false
        }
    }
}

check_enemy_player :: proc(){
    for &e in game.current_level.enemies{
        if rl.CheckCollisionCircleRec(game.player.hurt_collider.pos, game.player.hurt_collider.radius, e.rec) && game.player.health.invincible_timer <= 0{
            add_enemy_status_to_player(e, &game.player)
            game.player.health.take_dmg(&game.player.health, 10)
            game.player.health.invincible_timer = 2
        }
    }
}

add_enemy_status_to_player :: proc(e : Enemy, p : ^Player){
    for s in e.applied_status{

        if idx := check_if_entity_already_got_status(p.statuses, s); idx == -1{
            append(&p.statuses, s)
        } else {
            p.statuses[idx] = s
        }
    }
}

check_player_interact :: proc(){
    game.current_level.interact.interactable = nil
    for &n in game.current_level.npcs{
        if rl.CheckCollisionCircles(n.interactable.collider.pos, n.interactable.collider.radius,
        game.player.physics_collider.pos, game.player.radius){
            game.current_level.interact.interactable = any{data = rawptr(&n), id = typeid_of(NPC)}//&n
        }
    }
}

check_bullet_wall :: proc(b : ^Bullet){
    for layer in game.current_level.level_visual.layers{
        if layer.name != "Walls" do continue
        for obj in layer.objects{
            rect := rl.Rectangle{
                x = obj.x, y = obj.y,
                width = obj.width, height = obj.height,
            }

            if rl.CheckCollisionCircleRec(b.collider.pos, b.collider.radius, rect){
                b.is_active = false
                create_destroy_bullet_particle(b.pos)
            }
        }
    }
}

check_collisions_detection_loot :: proc(){
    for &l in game.current_level.loot{
        if l.is_following || !l.is_active do continue

        if rl.CheckCollisionCircles(l.detection.pos, l.detection.radius, game.player.pos, game.player.radius){
            l.is_following = true
        }
    }
}

check_collisions_pickup_loot :: proc(){
    for &l, idx in game.current_level.loot{
        if !l.is_active do continue

        if rl.CheckCollisionCircles(l.pickup.pos, l.pickup.radius, game.player.collector.pos, game.player.collector.radius){
            game.current_level.power_level_up = game.player.increase_value(&game.player.loot_bag, l.value)
            if game.current_level.power_level_up{
                level_up_spawner_update()
                create_upgrade_menu(&game.current_level.upgrade_menu, game.current_level.available_upgrades, game.player.target_ability)
            }
            unordered_remove(&game.current_level.loot, idx)
        }
    }
}

check_collision_upgrade_slot :: proc(){
    mouse_pos := rl.GetMousePosition()
    if !game.current_level.upgrade_menu.is_active && rl.IsMouseButtonReleased(.LEFT){
        game.current_level.upgrade_menu.is_active = true
        return
    }
    for &slot in game.current_level.upgrade_menu.upgrades{
        if rl.CheckCollisionPointRec(mouse_pos, slot.rect){
            slot.state = .Focused
            if rl.IsMouseButtonReleased(.LEFT) && game.current_level.upgrade_menu.is_active{
                slot.state = .Selected
            }
        } else{
            slot.state = .None
        }
    }
}

check_collision_menu :: proc(){
    for &element in game.menu.elements{
        switch &e in element{
            case ui.UI_Cooldown:
            case ui.UI_Button:
                check_collision_button(&e)
            case ui.UI_Menu:
            case ui.UI_Progress_Bar:
            case ui.UI_Label:
            case ui.UI_Slider:
                check_collision_slider(&e)
            case ui.UI_Status_Bar:
            case ui.UI_Skill_Tree:
                for &n in e.nodes{
                    check_node_focusing(&n)
                }
        }
    }
}

check_collision_button :: proc(b : ^ui.UI_Button){
    mouse_pos := rl.GetMousePosition()

    if rl.CheckCollisionPointRec(mouse_pos, b.rec){
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

check_in_game_ui_tooltip :: proc(){
    game.tooltip_ptr = nil
    for &element in game.current_level.ui_elements{
        switch &e in element{
            case ui.UI_Cooldown:
            case ui.UI_Button:
            case ui.UI_Menu:
            case ui.UI_Progress_Bar:
                check_mouse_progress_bar(&e)
            case ui.UI_Label:
            case ui.UI_Slider:
            case ui.UI_Status_Bar:
                for &s in e.slots{
                    check_mouse_status_slot(&s)
                }
            case ui.UI_Skill_Tree:
        }
    }

    if game.tooltip_ptr == nil{
        game.tooltip_timer = 0.25
    }
}

check_node_focusing :: proc(n : ^ui.UI_Skill_Node){
    mouse_pos := rl.GetMousePosition()
    if rl.CheckCollisionPointCircle(mouse_pos, n.pos, n.radius){
        n.state = .Focussed
        if rl.IsMouseButtonPressed(.LEFT){
            n.state = .Pressed
        }
    } else{
        n.state = .None
    }
}

check_mouse_status_slot :: proc(slot : ^ui.UI_Status_Slot){
    mouse_pos := rl.GetMousePosition()
    if rl.CheckCollisionPointRec(mouse_pos, slot.rec){
        game.tooltip_ptr = any{data = rawptr(slot), id = typeid_of(ui.UI_Status_Slot)}
        game.tooltip_pos = {slot.rec.x, slot.rec.y}
    }
}

check_mouse_progress_bar :: proc(pb : ^ui.UI_Progress_Bar){
    mouse_pos := rl.GetMousePosition()
    
    if rl.CheckCollisionPointRec(mouse_pos, pb.rec){
        game.tooltip_ptr = any{data = rawptr(pb), id = typeid_of(ui.UI_Progress_Bar)}
        game.tooltip_pos = {pb.rec.x, pb.rec.y}
    }
}