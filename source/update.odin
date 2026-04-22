package game

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"
import "handler"
import "ui"
import "collider"
import "loot"
import "core:math"

update_handler :: proc(g : ^Game_State, dt : f32){
    if rl.IsKeyPressed(.F1){
        g.is_paused = !g.is_paused
        clear(&g.menu.elements)
        ui.create_menu(&g.menu)
        if g.is_paused{
            g.current_menu = .Pause
            sync_menu(g)
        } else{
            clear(&g.menu.elements)
        }
    }

    if rl.IsKeyPressed(.Q){
        g.map_drawing = !g.map_drawing
    }

    if rl.IsKeyPressed(.U){
        g.current_level.power_level_up = true
        create_upgrade_menu(&g.current_level.upgrade_menu, g.current_level.available_upgrades, g.player.target_ability)
    }
}

update_helper :: proc(g : ^Game_State){
    if rl.IsKeyPressed(.F2){
        g.helper_activated = !g.helper_activated
    }

}

update_camera :: proc(g : ^Game_State, dt : f32){
    g.camera.target += handler.get_camera_follow_pos(g.player.pos, g.camera, dt)
    g.camera.offset = {f32(rl.GetScreenWidth())/2, f32(rl.GetScreenHeight())/2}
    if g.shake > 5{
        shake_x := g.camera.offset.x + rand.float32_range(-g.shake, g.shake)
        shake_y := g.camera.offset.y + rand.float32_range(-g.shake, g.shake)
        g.camera.offset = {shake_x, shake_y}
        g.shake *= 0.95
    }
}

update_player :: proc(g : ^Game_State, dt : f32){
    if g.player.health.is_dead{
        g.should_close = true
    }
    if g.player.health.invincible_timer >= 0{
        g.player.health.invincible_timer -= dt
    }
    if g.player.health.heal_amount > 0{
        g.player.health->heal(g.player.health.heal_amount)
        g.player.health.heal_amount = 0
    }
    g.player.vel = {}
    if rl.IsKeyDown(.W){
        g.player.vel.y = -check_direction_col(g^, g.player.pos, {0, -1}, g.player.speed, dt)
    }
    if rl.IsKeyDown(.D){
        g.player.vel.x = check_direction_col(g^, g.player.pos, {1, 0}, g.player.speed, dt)
    }
    if rl.IsKeyDown(.S){
        g.player.vel.y = check_direction_col(g^, g.player.pos, {0, 1}, g.player.speed, dt)
    }
    if rl.IsKeyDown(.A){
        g.player.vel.x = -check_direction_col(g^, g.player.pos, {-1, 0}, g.player.speed, dt)
    }

    g.player.pos += g.player.vel * g.player.speed * dt
    g.player.collider.pos = g.player.pos
    
    //Other player update stuff
    update_player_status(g, dt)
}

update_player_status :: proc(g : ^Game_State, dt : f32){
    for &s, idx in g.player.statuses{
        s.apply(&g.player, &s, dt)
        if s.state == .Applied{
            s.state = .None
            s.create_particle(&g.current_level.particles, g.player.pos)
        }
        if !s.is_active{
            unordered_remove(&g.player.statuses, idx)
        }
    }
}

update_player_bullets :: proc(g : ^Game_State, dt :f32){
    for &b, idx in g.current_level.player_bullets{
        b.vel = b.dir * b.speed
        b.pos += b.vel * dt
        b.collider.pos = b.pos
        if check_bullet_out_of_view(g.camera, b.pos){
            b.is_active = false
        }
        if !b.is_active{
            delete(b.hitted_enemies)
            clear(&b.applied_status)
            unordered_remove(&g.current_level.player_bullets, idx)
        }
    }
}

update_enemy_bullets :: proc(g : ^Game_State, dt : f32){
    for &b, idx in g.current_level.enemy_bullets{
        b.vel = b.dir * b.speed
        b.pos += b.vel * dt
        b.collider.pos = b.pos
        if check_bullet_out_of_view(g.camera, b.pos){
            b.is_active = false
        }
        if !b.is_active{
            delete(b.hitted_enemies)
            unordered_remove(&g.current_level.enemy_bullets, idx)
        }
    }
}

update_player_shooting :: proc(g : ^Game_State, dt : f32){
    if g.player.weapon.cooldown > 0{
        g.player.weapon.cooldown -= dt
    }

    if rl.IsMouseButtonDown(.LEFT) && g.player.weapon.cooldown <= 0{
        g.player.weapon.cooldown = g.player.weapon.fire_rate

        mouse_pos := rl.GetMousePosition()
        mouse_local_pos := rl.GetScreenToWorld2D(mouse_pos, g.camera)
        aim_dir := rl.Vector2Normalize(mouse_local_pos - g.player.pos)
        base_angle := math.to_degrees(math.atan2(aim_dir.y, aim_dir.x))
        
        total_spread : f32 = 45.0
        step := g.player.weapon.amount > 1 ? total_spread / (g.player.weapon.amount - 1) : 0
        start_angle := g.player.weapon.amount > 1 ? base_angle - (total_spread/2.0) : base_angle

        for i in 0..<g.player.weapon.amount{
            angle := start_angle + f32(i) * step
            dir : rl.Vector2
            dir.x = math.cos(math.to_radians(angle))
            dir.y = math.sin(math.to_radians(angle))
            b := g.player.weapon.bullet
            b.dir = dir
            b.pos = g.player.pos
            append(&g.current_level.player_bullets, b)
        }
    }
}

update_player_casting :: proc(g : ^Game_State, dt : f32){
    if g.player.ability_cd.cooldown > 0{
        g.player.ability_cd.cooldown -= dt
    }

    if rl.IsKeyPressed(.SPACE) && g.player.ability_cd.cooldown <= 0{
        g.player.ability_cd.cooldown = g.player.ability_cd.cast_rate
        cast_player_ability(g)
    }
}

update_spawner :: proc(g : ^Game_State, dt : f32){
    for &s in g.current_level.spawner{
        if !s.is_active do continue
        if s.count >= s.max_count do continue
        if s.spawn_timer > 0{
            s.spawn_timer -= dt
            continue
        }
        new_enemy := s.enemy
        new_enemy.pos = handler.get_random_spawn_pos(g.camera)
        rect := rl.Rectangle{
            width = new_enemy.width + 20,
            height = 10,
            x = new_enemy.pos.x + 10,
            y = new_enemy.pos.y + 20,
        }
        new_enemy.health_bar = ui.create_progress_bar(rect, rl.BLACK, rl.GRAY, rl.RED)
        new_enemy.health_bar.value = new_enemy.health.current
        new_enemy.health_bar.max = new_enemy.health.max
        new_enemy.spawner = &s
        s.count += 1
        s.spawn_timer = s.spawn_time
        append(&g.current_level.enemies, new_enemy)
    }
}

update_enemy :: proc(g : ^Game_State, dt : f32){
    for &e, idx in g.current_level.enemies{
        if e.health.is_dead{
            delete(e.statuses)
            e.on_death(g, e, i32(idx))
            continue
        }
        kb_speed := rl.Vector2Length(e.knocback.vel)
        if kb_speed > e.knocback.threshold{
            e.pos += e.knocback.vel * dt
            e.knocback.vel *= e.knocback.friction
            e.visual_scale.x = 1.0 + (kb_speed * 0.005)
            e.visual_scale.y = 1.0 - (kb_speed * 0.005)
        } else{
            e.visual_scale = {1, 1}
            switch &d in e.behavior {
                case Melee_Data:
                    melee_enemy_behavior(&e, d, g.player.pos, dt)
                case Distance_Data:
                    distance_enemy_behavior(&e, &d, g, dt)
                case Charge_Data:
                    charge_enemy_behavior(&e, &d, g, dt)
            }
        }
        
        e.origin = {e.pos.x + e.width/2, e.pos.y + e.height/2}
        e.collidor.pos = e.pos
        e.health_bar.value = e.health.current
        e.health_bar.rect.x = e.pos.x - 10
        e.health_bar.rect.y = e.pos.y - 20
        update_enemy_status(g, &e, dt)
    }
    
}

update_enemy_status :: proc(g : ^Game_State, e : ^Enemy, dt : f32){

    for &s, idx in e.statuses{
        s.apply(e, &s, dt)
        if s.state == .Applied{
            s.state = .None
            s.create_particle(&g.current_level.particles, e.origin)
        }
        if !s.is_active{
            unordered_remove(&e.statuses, idx)
        }
    }
}

update_fragement :: proc(g : ^Game_State, dt : f32){
    for &f, idx in g.current_level.enemy_fragments{
        f.life_time -= dt
        if f.move_time > 0{
            f.pos += f.vel * f.speed * dt
            f.move_time -= dt
        }
        if f.life_time <= 0{
            unordered_remove(&g.current_level.enemy_fragments, idx)
        }
    }
}

update_particle :: proc(g : ^Game_State, dt : f32){
    for &p, idx in g.current_level.particles{
        if !p.alive{
            unordered_remove(&g.current_level.particles, idx)
        }
        p.life += dt
        p.pos += p.vel * dt
        if p.life >= p.max_life{
            p.alive = false
        }
    }
}

update_loot :: proc(g : ^Game_State, dt : f32){
    for &l in g.current_level.loot{
        if !l.is_active{
            l.time -= dt
            if l.time <= 0{
                l.is_active = true
                continue
            }
            l.pos += l.dir * l.speed * dt
            l.detection.pos = {l.pos.x + l.size.x/2, l.pos.y + l.size.y/2}
            l.pickup.pos = {l.pos.x + l.size.x/2, l.pos.y + l.size.y/2}
        }
        if !l.is_following do continue
        dir := g.player.pos - l.pos
        dir = rl.Vector2Normalize(dir)

        if l.current_speed <= l.max_speed{
            l.current_speed += l.acceleration
        }

        l.pos += dir * l.current_speed * dt
        l.detection.pos = {l.pos.x + l.size.x/2, l.pos.y + l.size.y/2}
        l.pickup.pos = {l.pos.x + l.size.x/2, l.pos.y + l.size.y/2}
    }
}

update_upgrade :: proc(g : ^Game_State, dt : f32){
    g.current_level.upgrade_menu.width = f32(rl.GetScreenWidth())
    g.current_level.upgrade_menu.height = f32(rl.GetScreenHeight())
    for i in 0..<3{
        slot := g.current_level.upgrade_menu.upgrades[i]
        slot.rect.x = g.current_level.upgrade_menu.width * 0.1 + slot.rect.width * f32(i) + 50 * f32(i)
        slot.rect.width = g.current_level.upgrade_menu.width * 0.25
        slot.rect.height = g.current_level.upgrade_menu.height * 0.75
        g.current_level.upgrade_menu.upgrades[i] = slot
    }
    for &slot in g.current_level.upgrade_menu.upgrades{
        if slot.state == .Selected{
            on_upgrade(g, slot.upgrade)
            g.current_level.power_level_up = false
        }
    }
}

update_in_game_ui :: proc(g : ^Game_State, dt : f32){
    for &element in g.current_level.ui_elements{
        switch &e in element{
            case ui.UI_Progress_Bar:
                if e.type == .Health{
                    update_progress_bar(&e, g.player.health.current, g.player.health.max)
                } else if e.type == .Value{
                    update_progress_bar(&e, g.player.loot_bag.value, g.player.loot_bag.max_value)
                }
            case ui.UI_Cooldown:
                update_cooldown(&e, g.player.ability_cd.cooldown, g.player.ability_cd.cast_rate)
            case ui.UI_Button:
            case ui.UI_Menu:
            case ui.UI_Label:
            case ui.UI_Slider:
            case ui.UI_Status_Bar:
                update_status_bar(g.player, &e)
        }
    }
}

update_menu :: proc(g : ^Game_State){
    for &element in g.menu.elements{
        if test, ok := element.(ui.UI_Cooldown); ok{

        }
        switch &e in element{
            case ui.UI_Cooldown:
                update_cooldown(&e, g.player.ability_cd.cooldown, g.player.ability_cd.cast_rate)
            case ui.UI_Button:
                update_button(&e)
                if e.state == .Pressed{
                    check_which_btn_was_pressed(g, &e)
                }
            case ui.UI_Menu:
            case ui.UI_Progress_Bar:
            case ui.UI_Label:
            case ui.UI_Slider:
                update_slider(&e)
            case ui.UI_Status_Bar:
        } 
    }
}

update_progress_bar :: proc(bar : ^ui.UI_Progress_Bar, value : f32, max : f32){
    bar.value = value
    bar.max = max
}

update_button :: proc(b : ^ui.UI_Button){
    switch b.state{
        case .None: b.color = b.n_color
        case .Focus: b.color = b.f_color
        case .Pressing: b.color = b.p_color
        case .Pressed: b.color = b.p_color
    }
}

update_cooldown :: proc(cd : ^ui.UI_Cooldown, value : f32, max : f32){
    cd.value = value
    cd.max = max
}

update_slider :: proc(s : ^ui.UI_Slider){
    switch s.state{
        case .None:
            s.color = s.n_color
        case .Active:
            s.color = s.a_color
            s.slider.x = rl.GetMousePosition().x
    }

}

update_status_bar :: proc(p : Player, sbar : ^ui.UI_Status_Bar){
    clear(&sbar.slots)
    width : f32 = 20
    height : f32 = 20
    for i in 0..<len(p.statuses){
        x := sbar.pos.x + (width + sbar.seperation) * f32(i)
        y := sbar.pos.y
        slot := ui.create_status_slot({x, y}, width, height, p.statuses[i].texture)
        append(&sbar.slots, slot)
    }
}

check_direction_col :: proc(g : Game_State, pos : rl.Vector2, vel : rl.Vector2, speed : f32, dt : f32) -> f32{
    n_vel := rl.Vector2Normalize(vel)
    next_pos := pos + vel * speed * dt
    if check_player_wall(next_pos, g.player.radius, g){
        return 0
    }
    return 1
}

check_bullet_out_of_view :: proc(c : rl.Camera2D, pos : rl.Vector2) -> bool{
    c_world := handler.get_camera_world_position(c)
    return pos.x < c_world.left || pos.x > c_world.right || pos.y < c_world.top || pos.y > c_world.bottom 
}
