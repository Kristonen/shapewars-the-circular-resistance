package game

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"
import "handler"
import "ui"
import "collider"
import "core:math"

update_handler :: proc(dt : f32){
    if rl.IsKeyPressed(.ESCAPE){
        if game.player.ability.indicator_active{
            game.player.ability.indicator_active = false
            game.level.indicator = nil
            return
        }
        clear(&game.menu.elements)
        switch game.current_menu{
            case .Play:
                game.is_paused = true
                game.current_menu = .Pause
            case .Pause:
                game.is_paused = false
                game.current_menu = .Play
            case .Main:
            case .Options:
                game.current_menu = game.last_menu
            case .Gunsmith:
                game.is_paused = false
                game.current_menu = .Play
            case .Skilltree:
                game.current_menu = game.last_menu
            case .ChooseLevel:
                game.is_paused = false
                game.current_menu = .Play
            case .Catalyst:
                game.is_paused = false
                game.current_menu = .Play
            case .Quartermaster:
                game.is_paused = false
                game.current_menu = .Play
            case .Craftman:
                game.is_paused = false
                game.current_menu = .Play
            case .EquiptmentBullet:
                game.current_menu = game.last_menu
            case .EquiptmentAbility:
                game.current_menu = game.last_menu
            case .Stats:
                game.is_paused = false
                game.current_menu = .Play
        }
        sync_menu()
    }

    if rl.IsKeyPressed(.Q){
        game.map_drawing = !game.map_drawing
    }

    if rl.IsKeyPressed(.U){
        game.level.power_level_up = true
        create_upgrade_menu(&game.level.upgrade_menu, game.level.available_upgrades)
    }

    if rl.IsKeyPressed(.TAB){
        game.is_paused = !game.is_paused
        game.current_menu = game.is_paused ? .Stats : .Play
        sync_menu()
    }

    if rl.IsKeyPressed(.H){
        create_level(.HQ)
    }

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
    if !game.player.ignore_input{
        game.player.pos += game.player.vel * game.player.speed * dt
    }
    
    //Update player colliders
    game.player.hurt_collider.pos = game.player.pos
    game.player.collector.pos = game.player.pos
    game.player.physics_collider.pos = game.player.pos
    
    //Other player update stuff
    update_player_status(dt)

    //Ghosts Updaten
    for i in 0..<len(game.player.ghosts){
        if game.player.ghosts[i].life <= 0 do continue
        game.player.ghosts[i].life -= dt
    }
}

update_player_status :: proc(dt : f32){
    for &s, idx in game.player.statuses{
        s.apply(&game.player, &s, dt)
        if s.state == .Applied{
            s.state = .None
            rec := rl.Rectangle {
                x = game.player.pos.x - game.player.radius/2,
                y = game.player.pos.y - game.player.radius/2,
                width = game.player.radius,
                height = game.player.radius,
            }
            s.create_particle(rec)
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
    if game.player.ability.indicator_active do return
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
    // cd := get_ability_cd()
    // if cd.cooldown > 0{
    //     cd.cooldown -= dt
    // }

    // if game.player.ability.indicator_active{
    //     game.player.ability.indicator(&game.player.ability, dt)
    // }

    // if rl.IsKeyPressed(.SPACE) && cd.cooldown <= 0 && !game.player.ability.active && !game.player.ability.casting{
    //     // game.player.ability.cd.cooldown = game.player.ability.cd.cast_rate
    //     // game.player.ability.activate(dt)
    //     game.player.ability.indicator_active = true
    // }

    update_ability(&game.player.ability, dt, .Player)

    // if game.player.ability.activated{
    //     game.player.ability.indicator_active = false
    //     game.player.ability.activated = false
    //     game.player.ability.active = true
    //     game.player.ability.cd.cooldown = game.player.ability.cd.cast_rate
    //     game.player.ability.activate(dt)
    //     game.level.indicator = nil
    // }

    // if game.player.ability.active{
    //     game.player.ability.update(dt)
    // }
}

update_ability :: proc(a : ^Ability, dt : f32, type : Ability_Owner, d : ^Behavior_Data = nil){

    if a.cd.cooldown > 0{
        a.cd.cooldown -= dt
    }

    if a.cast_timer.cooldown > 0{
        a.cast_timer.cooldown -= dt
    }

    if type == .Player{

        if a.indicator_active{
            a.indicator(a, dt)
        }

        if rl.IsKeyPressed(.SPACE) && a.cd.cooldown <= 0 && !a.active && !a.casting{
            // game.player.ability.cd.cooldown = game.player.ability.cd.cast_rate
            // game.player.ability.activate(dt)
            a.indicator_active = true
        }
    } else{
        if a.cd.cooldown <= 0 && !a.active && !a.casting{
            data := &d.(Boss_Data)
            a.indicator(a, dt)
            data.is_casting = true
        }
    }

    if a.active{
        a.update(a, dt)
    }

    if a.casting && a.cast_timer.cooldown <= 0 && !a.active{
        a.casting = false
        a.activated = true
    }

    if a.activated{
        a.indicator_active = false
        a.activated = false

        a.active = true
        a.cd.cooldown = a.cd.cast_rate
        a.activate(a, dt)
        if type == .Player{
            game.level.indicator = nil
        }
    }

    if a.finished{
        a.finish(a, dt)
        a.active = false
        a.finished = false
        if type == .Enemy{
            data := &d.(Boss_Data)
            data.is_casting = false
        }
    }
}

update_player_indicator :: proc(dt : f32){
    if game.level.indicator == nil do return
    switch &i in game.level.indicator{
        case AoE_Indicator:
            i.pos = rl.GetMousePosition()
        case Line_Indicator:
    }
}

update_player_interact :: proc(dt : f32){
    if game.level.interact.interactable == nil do return

    if rl.IsKeyPressed(.E){
        switch &e in game.level.interact.interactable{
            case NPC:
                e.interactable.action()
            case Portal:
                e.interact.action()
            case Chest:
                e.interact.action()
        }
    }
}

update_ability_projectiles :: proc(dt : f32){
    for i := 0; i < len(game.level.ability_projectiles);{
        p := &game.level.ability_projectiles[i]
        if rl.Vector2Distance({p.rec.x, p.rec.y}, p.target_pos) > 10{
            p.rec.x += p.dir.x * p.speed * dt
            p.rec.y += p.dir.y * p.speed * dt
        } else{
            unordered_remove(&game.level.ability_projectiles, i)
            continue
        }
        i += 1
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
        if e.hit_timer > 0{
            e.hit_timer -= dt
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
            e->behave(&e.behavior, dt)
        }
        
        e.origin = {e.rec.x + e.rec.width/2, e.rec.y + e.rec.height/2}
        e.collidor.rec.x = e.rec.x
        e.collidor.rec.y = e.rec.y
        e.health_bar.value = e.health.current
        e.health_bar.rec.x = e.rec.x - 10
        e.health_bar.rec.y = e.rec.y - 20
        update_enemy_status(&e, dt)
        
        switch &data in e.behavior{
            case Melee_Data:
            case Distance_Data:
            case Charge_Data:
            case Boss_Data:
                // if data.is_casting do return
                for &s in data.abilities{
                    if !s.active do continue
                    update_enemy_ability(&e, dt)
                    update_ability(&s.ability, dt, .Enemy, &e.behavior)
                }
        }
    }
}

update_enemy_status :: proc(e : ^Enemy, dt : f32){

    for &s, idx in e.statuses{
        s.apply(e, &s, dt)
        if s.state == .Applied{
            s.state = .None
            s.create_particle(e.rec)
        }
        if !s.is_active{
            unordered_remove(&e.statuses, idx)
        }
    }
}

update_enemy_ability :: proc(e : ^Enemy, dt : f32){
    data, ok := &e.behavior.(Boss_Data)
    if !ok do return

    for &s in data.abilities{
        switch &d in s.ability.data{
            case Radial_Liberation_Data:
            case Dash_Data:
            case Bomb_Data:
            case Reinforcment_Data:
                d.pos = e.origin
        }
    }
}

update_area_effect :: proc(dt : f32){
    for &a, idx in game.level.area_effects{
        if a.duration > 0{
            a.duration -= dt
        } else{
            unordered_remove(&game.level.area_effects, idx)
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

update_portal :: proc(dt : f32){
    update_animation(&game.level.portal.animation, dt)
}

update_animation :: proc(a : ^Animation, dt : f32){
    if a.is_finished do return
    a.duration_left -= dt
    if a.duration_left <= 0{
        a.duration_left = a.speed
        a.current_frame += a.anim_direction
        
        switch a.mode{
            case .Once:
                if a.current_frame > a.last_frame{
                    a.current_frame = a.last_frame
                    a.is_finished = true
                }
            case .Loop:
                if a.current_frame > a.last_frame{
                    a.current_frame = a.first_frame
                }
            case .Ping_Pong:
                if a.current_frame > a.last_frame{
                    a.anim_direction = -1
                    a.current_frame = a.last_frame - 1
                }
                if a.current_frame < a.first_frame{
                    a.anim_direction = 1
                    a.current_frame = 1
                }
        }
    }
}

update_particle :: proc(dt : f32){
    for i := 0; i < len(game.level.particles);{
        p := &game.level.particles[i]
        if p.life >= p.max_life{
            p.alive = false
        }
        if !p.alive{
            unordered_remove(&game.level.particles, i)
            continue
        }
        if p.use_grav{
            p.vel.y += Fake_Particle_Gravitiy
        }
        p.life += dt
        progress := p.life/p.max_life
        switch p.type{
            case .Normal:
                p.pos += p.vel * dt
            case .Line:
                p.pos += p.vel * dt
                p.vel *= 0.98
                // p.size = (p.life/p.max_life)*15.0
            case .Expanding:
                p.size = progress * 130.0
            case .PlasmaSmoke:
                p.pos += p.vel * dt
                p.vel *= 0.99
                p.size = (1.0 - progress) * 18.0
        }
        i += 1  
    }
}

update_loot :: proc(dt : f32){
    for i := 0; i < len(game.level.loot);{
        l := &game.level.loot[i]

        if l.state == .Collected{
            unordered_remove(&game.level.loot, i)
            continue
        }

        if l.state == .Spawning{//!l.is_active{
            l.on_spawn(l, dt)
            i += 1
            continue
        }

        if l.state == .Idle{//!l.is_following{
            i += 1
            continue
        }
        dir := game.player.pos - {l.rec.x + (l.rec.width/2), l.rec.y + (l.rec.height/2)}
        dir = rl.Vector2Normalize(dir)

        if l.current_speed <= l.max_speed{
            l.current_speed += l.acceleration
        }
        pos : rl.Vector2 = {l.rec.x, l.rec.y} + dir * l.current_speed * dt
        l.rec.x = pos.x
        l.rec.y = pos.y
        l.detection.pos = {l.rec.x + l.rec.width/2, l.rec.y + l.rec.height/2}
        l.pickup.pos = {l.rec.x + l.rec.width/2, l.rec.y + l.rec.height/2}
        i += 1
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
            case ui.UI_Panel:
        }
    }
    update_interact()
}

update_interact :: proc(){
    if game.level.interact.interactable == nil do return
    switch &e in game.level.interact.interactable{
        case NPC: 
            game.level.interact.text.content = e.interactable.text
        case Portal:
            game.level.interact.text.content = e.interact.text
        case Chest:
            game.level.interact.text.content = e.interact.text
    }
}

update_menu :: proc(){
    for &element in game.menu.elements{
        if test, ok := element.(ui.UI_Cooldown); ok{

        }
        switch &e in element{
            case ui.UI_Panel:
            case ui.UI_Cooldown:
                cd := get_ability_cd()
                update_cooldown(&e, cd.cooldown, cd.cast_rate)
            case ui.UI_Button:
                update_button(&e)
                if e.state == .Pressed{
                    e->on_click()
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

update_skilltree :: proc(){
    type := fmt.tprintf("%v", game.active_skilltree)
    for &n in game.skilltrees[type].nodes{
        update_skill_nodes(&n)
    }
    for &l in game.skilltrees[type].lines{
        update_skill_lines(&l)
    }
}

update_skill_nodes :: proc(n : ^UI_Skill_Node){
    n.used.content = fmt.tprintf("%i/%i", n.count, n.max_count)
    if n.state == .Spend || n.state == .Refund{
        refund := n.state == .Refund
        if refund{
            game.skill_points += 1
            n.count -= 1
        } else {
            game.skill_points -= 1
            n.count += 1
        }
        
        if game.active_skilltree != game.player.current_weapon && game.active_skilltree != game.player.current_ability do return
        n->apply(refund)
        n.state = .None
    }
}

update_skill_lines :: proc(l : ^UI_Skill_Line){
    type := fmt.tprintf("%v", game.active_skilltree)
    from := &game.skilltrees[type].nodes[l.from_idx]
    to := &game.skilltrees[type].nodes[l.to_idx]
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

    if b.text.content == "Buy"{
        switch type in b.data{
            case Unlocked_Data_Type:
                u, i := get_unlockable(type)
                b.disabled = u.blueprints < 1 && u.cost < game.shards
        }
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
