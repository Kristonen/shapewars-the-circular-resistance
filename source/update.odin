package game

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"
import "handler"
import "ui"
import "collider"
import "loot"
import "core:math"

update_handler :: proc(dt : f32){
    if rl.IsKeyPressed(.F1){
        game.is_paused = !game.is_paused
        clear(&game.menu.elements)
        ui.create_menu(&game.menu)
        if game.is_paused{
            game.current_menu = .Pause
            sync_menu()
        } else{
            clear(&game.menu.elements)
        }
    }

    if rl.IsKeyPressed(.Q){
        game.map_drawing = !game.map_drawing
    }

    if rl.IsKeyPressed(.U){
        game.level.power_level_up = true
        create_upgrade_menu(&game.level.upgrade_menu, game.level.available_upgrades, game.player.target_ability)
    }
}

update_helper :: proc(){
    if rl.IsKeyPressed(.F2){
        game.helper_activated = !game.helper_activated
    }

}

update_camera :: proc(dt : f32){
    game.camera.target += handler.get_camera_follow_pos(game.player.pos, game.camera, dt)
    game.camera.offset = {f32(rl.GetScreenWidth())/2, f32(rl.GetScreenHeight())/2}
    if game.shake > 5{
        shake_x := game.camera.offset.x + rand.float32_range(-game.shake, game.shake)
        shake_y := game.camera.offset.y + rand.float32_range(-game.shake, game.shake)
        game.camera.offset = {shake_x, shake_y}
        game.shake *= 0.95
    }
}

update_player :: proc(dt : f32){
    if game.player.health.is_dead{
        game.should_close = true
    }
    if game.player.health.invincible_timer >= 0{
        game.player.health.invincible_timer -= dt
    }
    if game.player.health.heal_amount > 0{
        game.player.health->heal(game.player.health.heal_amount)
        game.player.health.heal_amount = 0
    }
    game.player.vel = {}
    if rl.IsKeyDown(.W){
        game.player.vel.y = -check_direction_col({0, -1}, dt)
    }
    if rl.IsKeyDown(.D){
        game.player.vel.x = check_direction_col({1, 0}, dt)
    }
    if rl.IsKeyDown(.S){
        game.player.vel.y = check_direction_col({0, 1}, dt)
    }
    if rl.IsKeyDown(.A){
        game.player.vel.x = -check_direction_col({-1, 0}, dt)
    }

    game.player.pos += game.player.vel * game.player.speed * dt
    //Update player colliders
    game.player.hurt_collider.pos = game.player.pos
    game.player.collector.pos = game.player.pos
    game.player.physics_collider.pos = game.player.pos
    
    //Other player update stuff
    update_player_status(dt)
}

update_player_status :: proc(dt : f32){
    for &s, idx in game.player.statuses{
        s.apply(&game.player, &s, dt)
        if s.state == .Applied{
            s.state = .None
            s.create_particle(game.player.pos)
        }
        if !s.is_active{
            unordered_remove(&game.player.statuses, idx)
        }
    }
}

update_npc :: proc(dt : f32){
    for &n in game.level.npcs{
        n.interactable.collider.pos = n.pos
    }
}

update_player_bullets :: proc(dt :f32){
    for &b, idx in game.level.player_bullets{
        b.vel = b.dir * b.speed
        b.pos += b.vel * dt
        b.collider.pos = b.pos
        if check_bullet_out_of_view(b.pos){
            b.is_active = false
        }
        if !b.is_active{
            delete(b.hitted_enemies)
            clear(&b.applied_status)
            unordered_remove(&game.level.player_bullets, idx)
        }
    }
}

update_enemy_bullets :: proc(dt : f32){
    for &b, idx in game.level.enemy_bullets{
        b.vel = b.dir * b.speed
        b.pos += b.vel * dt
        b.collider.pos = b.pos
        if check_bullet_out_of_view(b.pos){
            b.is_active = false
        }
        if !b.is_active{
            delete(b.hitted_enemies)
            unordered_remove(&game.level.enemy_bullets, idx)
        }
    }
}

update_player_shooting :: proc(dt : f32){
    if game.player.weapon.cooldown > 0{
        game.player.weapon.cooldown -= dt
    }

    if rl.IsMouseButtonDown(.LEFT) && game.player.weapon.cooldown <= 0{
        game.player.weapon.cooldown = game.player.weapon.fire_rate

        mouse_pos := rl.GetMousePosition()
        mouse_local_pos := rl.GetScreenToWorld2D(mouse_pos, game.camera)
        aim_dir := rl.Vector2Normalize(mouse_local_pos - game.player.pos)
        base_angle := math.to_degrees(math.atan2(aim_dir.y, aim_dir.x))
        
        total_spread : f32 = 45.0
        step := game.player.weapon.amount > 1 ? total_spread / (game.player.weapon.amount - 1) : 0
        start_angle := game.player.weapon.amount > 1 ? base_angle - (total_spread/2.0) : base_angle

        for i in 0..<game.player.weapon.amount{
            angle := start_angle + f32(i) * step
            dir : rl.Vector2
            dir.x = math.cos(math.to_radians(angle))
            dir.y = math.sin(math.to_radians(angle))
            b := game.player.weapon.bullet
            b.dir = dir
            b.pos = game.player.pos
            append(&game.level.player_bullets, b)
        }
    }
}

update_player_casting :: proc(dt : f32){
    cd := get_ability_cd()
    if cd.cooldown > 0{
        cd.cooldown -= dt
    }

    if rl.IsKeyPressed(.SPACE) && cd.cooldown <= 0{
        switch &a in game.player.ability{
            case Radial_Liberation:
                cd.cooldown = a.ability_cd.cast_rate
            case Dash:
                cd.cooldown = a.ability_cd.cast_rate
        }
        cast_player_ability()
    }
}

update_player_interact :: proc(dt : f32){
    if game.level.interact.interactable == nil do return

    if rl.IsKeyPressed(.E){
        switch &e in game.level.interact.interactable{
            case NPC:
                e.interactable.action()
        }
    }
}

update_spawner :: proc(dt : f32){
    for &s in game.level.spawner{
        if !s.is_active do continue
        if s.count >= s.max_count do continue
        if s.spawn_timer > 0{
            s.spawn_timer -= dt
            continue
        }
        new_e := s.enemy
        pos := handler.get_random_spawn_pos(game.camera)
        new_e.rec.x = pos.x
        new_e.rec.y = pos.y
        rec := rl.Rectangle{
            width = new_e.rec.width + 20,
            height = 10,
            x = new_e.rec.x + 10,
            y = new_e.rec.y + 20,
        }
        new_e.health_bar = ui.create_progress_bar(rec, rl.BLACK, rl.GRAY, rl.RED)
        new_e.health_bar.value = new_e.health.current
        new_e.health_bar.max = new_e.health.max
        new_e.spawner = &s
        s.count += 1
        s.spawn_timer = s.spawn_time
        append(&game.level.enemies, new_e)
    }
}

update_enemy :: proc(dt : f32){
    for &e, idx in game.level.enemies{
        if e.health.is_dead{
            delete(e.statuses)
            e.on_death(e, i32(idx))
            continue
        }
        kb_speed := rl.Vector2Length(e.knocback.vel)
        if kb_speed > e.knocback.threshold{
            pos : rl.Vector2 = {e.rec.x, e.rec.y}
            pos += e.knocback.vel * dt
            e.rec.x = pos.x
            e.rec.y = pos.y
            e.knocback.vel *= e.knocback.friction
            e.visual_scale.x = 1.0 + (kb_speed * 0.005)
            e.visual_scale.y = 1.0 - (kb_speed * 0.005)
        } else{
            e.visual_scale = {1, 1}
            switch &d in e.behavior {
                case Melee_Data:
                    melee_enemy_behavior(&e, d, game.player.pos, dt)
                case Distance_Data:
                    distance_enemy_behavior(&e, &d, &game, dt)
                case Charge_Data:
                    charge_enemy_behavior(&e, &d, &game, dt)
            }
        }
        
        e.origin = {e.rec.x + e.rec.width/2, e.rec.y + e.rec.height/2}
        e.collidor.rec.x = e.rec.x
        e.collidor.rec.y = e.rec.y
        e.health_bar.value = e.health.current
        e.health_bar.rec.x = e.rec.x - 10
        e.health_bar.rec.y = e.rec.y - 20
        update_enemy_status(&e, dt)
    }
    
}

update_enemy_status :: proc(e : ^Enemy, dt : f32){

    for &s, idx in e.statuses{
        s.apply(e, &s, dt)
        if s.state == .Applied{
            s.state = .None
            s.create_particle(e.origin)
        }
        if !s.is_active{
            unordered_remove(&e.statuses, idx)
        }
    }
}

update_fragement :: proc(dt : f32){
    for &f, idx in game.level.enemy_fragments{
        f.life_time -= dt
        if f.move_time > 0{
            f.pos += f.vel * f.speed * dt
            f.move_time -= dt
        }
        if f.life_time <= 0{
            unordered_remove(&game.level.enemy_fragments, idx)
        }
    }
}

update_particle :: proc(dt : f32){
    for &p, idx in game.level.particles{
        if !p.alive{
            unordered_remove(&game.level.particles, idx)
        }
        p.life += dt
        p.pos += p.vel * dt
        if p.life >= p.max_life{
            p.alive = false
        }
    }
}

update_loot :: proc(dt : f32){
    for &l in game.level.loot{
        if !l.is_active{
            l.time -= dt
            if l.time <= 0{
                l.is_active = true
                continue
            }
            pos : rl.Vector2 = {l.rec.x, l.rec.y} + l.dir * l.speed * dt
            l.rec.x = pos.x
            l.rec.y = pos.y
            l.detection.pos = {l.rec.x + l.rec.width/2, l.rec.y + l.rec.height/2}
            l.pickup.pos = {l.rec.x + l.rec.width/2, l.rec.y + l.rec.height/2}
        }
        if !l.is_following do continue
        dir := game.player.pos - {l.rec.x, l.rec.y}
        dir = rl.Vector2Normalize(dir)

        if l.current_speed <= l.max_speed{
            l.current_speed += l.acceleration
        }
        pos : rl.Vector2 = {l.rec.x, l.rec.y} + dir * l.current_speed * dt
        l.rec.x = pos.x
        l.rec.y = pos.y
        l.detection.pos = {l.rec.x + l.rec.width/2, l.rec.y + l.rec.height/2}
        l.pickup.pos = {l.rec.x + l.rec.width/2, l.rec.y + l.rec.height/2}
    }
}

update_upgrade :: proc(dt : f32){
    game.level.upgrade_menu.width = f32(rl.GetScreenWidth())
    game.level.upgrade_menu.height = f32(rl.GetScreenHeight())
    for i in 0..<3{
        slot := game.level.upgrade_menu.upgrades[i]
        slot.rect.x = game.level.upgrade_menu.width * 0.1 + slot.rect.width * f32(i) + 50 * f32(i)
        slot.rect.width = game.level.upgrade_menu.width * 0.25
        slot.rect.height = game.level.upgrade_menu.height * 0.75
        game.level.upgrade_menu.upgrades[i] = slot
    }
    for &slot in game.level.upgrade_menu.upgrades{
        if slot.state == .Selected{
            on_upgrade(slot.upgrade)
            game.level.power_level_up = false
        }
    }
}

update_in_game_ui :: proc(dt : f32){
    for &element in game.level.ui_elements{
        switch &e in element{
            case ui.UI_Progress_Bar:
                if e.type == .Health{
                    update_progress_bar(&e, game.player.health.current, game.player.health.max)
                } else if e.type == .Value{
                    update_progress_bar(&e, game.player.loot_bag.value, game.player.loot_bag.max_value)
                }
            case ui.UI_Cooldown:
                cd := get_ability_cd()
                update_cooldown(&e, cd.cooldown, cd.cast_rate)
            case ui.UI_Button:
            case ui.UI_Menu:
            case ui.UI_Label:
            case ui.UI_Slider:
            case ui.UI_Status_Bar:
                update_status_bar(&e)
            case ui.UI_Skill_Tree:
        }
    }
    update_interact()
}

update_interact :: proc(){
    if game.level.interact.interactable == nil do return
    switch &e in game.level.interact.interactable{
        case NPC: 
            game.level.interact.text.content = e.interactable.text
    }
}

update_menu :: proc(){
    for &element in game.menu.elements{
        if test, ok := element.(ui.UI_Cooldown); ok{

        }
        switch &e in element{
            case ui.UI_Cooldown:
                cd := get_ability_cd()
                update_cooldown(&e, cd.cooldown, cd.cast_rate)
            case ui.UI_Button:
                update_button(&e)
                if e.state == .Pressed{
                    e->on_click()
                    // check_which_btn_was_pressed(&e)
                }
            case ui.UI_Menu:
            case ui.UI_Progress_Bar:
            case ui.UI_Label:
            case ui.UI_Slider:
                update_slider(&e)
            case ui.UI_Status_Bar:
            case ui.UI_Skill_Tree:
                for &n in e.nodes{
                    update_skill_nodes(&n)
                }
                for &l in e.lines{
                    update_skill_lines(&l, &e.nodes)
                }
        } 
    }
}

update_skill_nodes :: proc(n : ^ui.UI_Skill_Node){
    n.used.content = fmt.tprintf("%i/%i", n.count, n.max_count)
    if n.state == .Pressed{
        n->apply()
    }
}

update_skill_lines :: proc(l : ^ui.UI_Skill_Line, nodes : ^[dynamic]ui.UI_Skill_Node){
    from := &nodes[l.from_idx]
    to := &nodes[l.to_idx]
    if from.count >= to.needed_count{
        to.is_active = true
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

update_status_bar :: proc(sbar : ^ui.UI_Status_Bar){
    clear(&sbar.slots)
    width : f32 = 20
    height : f32 = 20
    for i in 0..<len(game.player.statuses){
        x := sbar.pos.x + (width + sbar.seperation) * f32(i)
        y := sbar.pos.y
        slot := ui.create_status_slot({x, y}, width, height, game.player.statuses[i].texture)
        slot.text = fmt.tprintf("%v", game.player.statuses[i].type)
        append(&sbar.slots, slot)
    }
}

update_tooltip :: proc(dt : f32){
    if game.tooltip_ptr == nil do return

    if game.tooltip_timer > 0{
        game.tooltip_timer -= dt
    }

    switch &t in game.tooltip_ptr{
        case ui.UI_Status_Slot:
            game.tooltip = ui.create_tooltip({t.rec.x, t.rec.y})
            game.tooltip.text.content = t.text
            game.tooltip.text.font_size = 20
            game.tooltip.text.text_color = rl.WHITE
        case ui.UI_Progress_Bar:
            game.tooltip = ui.create_tooltip({t.rec.x, t.rec.y})
            game.tooltip.text.content = fmt.tprintf("%0.0f/%0.0f", t.value, t.max)       
            game.tooltip.text.text_color = rl.WHITE
    }
}

check_direction_col :: proc(vel : rl.Vector2, dt : f32) -> f32{
    n_vel := rl.Vector2Normalize(vel)
    next_pos := game.player.pos + vel * game.player.speed * dt
    if check_player_wall(next_pos, game.player.physics_collider.radius) || check_player_npc(next_pos){
        return 0
    }
    return 1
}

check_bullet_out_of_view :: proc(pos : rl.Vector2) -> bool{
    c_world := handler.get_camera_world_position(game.camera)
    return pos.x < c_world.left || pos.x > c_world.right || pos.y < c_world.top || pos.y > c_world.bottom 
}
