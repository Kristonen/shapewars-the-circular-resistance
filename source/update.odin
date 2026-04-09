package game

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"
import "handler"
import "ui"
import "collider"
import "bullet"
import "enemy"
import "loot"
import "upgrade"

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
        g.level_up = true
        upgrade.create_upgrade_menu(&g.upgrade_menu, g.available_upgrades, g.player.target_ability)
    }
}

update_manual_spawn :: proc(g : ^Game_State){
    if rl.IsKeyPressed(.T){
        new_pos := handler.get_random_spawn_pos(g.camera)
        e := enemy.create_enemy(new_pos)
        append(&g.enemies, e)
    }
}

update_helper :: proc(g : ^Game_State){
    if rl.IsKeyPressed(.F2){
        g.helper_activated = !g.helper_activated
    }

}

update_player :: proc(g : ^Game_State, dt : f32){
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
}

update_player_bullets :: proc(g : ^Game_State, dt :f32){
    for &b, idx in g.player_bullets{
        b.vel = b.dir * b.speed
        b.pos += b.vel * dt
        b.collider.pos = b.pos
        if check_bullet_out_of_view(g.camera, b.pos){
            b.is_active = false
        }
        if !b.is_active{
            unordered_remove(&g.player_bullets, idx)
        }
    }
}

update_player_shooting :: proc(g : ^Game_State, dt : f32){
    if g.player.weapon.cooldown > 0{
        g.player.weapon.cooldown -= dt
    }

    if rl.IsMouseButtonDown(.LEFT) && g.player.weapon.cooldown <= 0{
        g.player.weapon.cooldown = g.player.weapon.fire_rate
        b := g.player.bullet
        b.pos = g.player.pos
        mouse_pos := rl.GetMousePosition()
        dir := rl.GetScreenToWorld2D(mouse_pos, g.camera)
        b.dir = rl.Vector2Normalize(dir - g.player.pos)
        append(&g.player_bullets, b)
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

update_enemies :: proc(g : ^Game_State, dt : f32){
    for &e, idx in g.enemies{
        if e.health.is_dead{
            // loot.create_simple_shard(&g.loot, e.pos)
            count := rand.int32_range(3, 7)
            loot.spawn_shards(&g.loot, count, e.pos)
            unordered_remove(&g.enemies, idx)
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
            e.update_behavior(&e, g.player.pos, dt)
        }
        
        e.origin = {e.pos.x + e.width/2, e.pos.y + e.height/2}
        e.collidor.pos = e.pos
        e.health_bar.value = e.health.current
        e.health_bar.rect.x = e.pos.x - 10
        e.health_bar.rect.y = e.pos.y - 20
    }
}

update_particle :: proc(g : ^Game_State, dt : f32){
    for &p, idx in g.particles{
        if !p.alive{
            unordered_remove(&g.particles, idx)
        }
        p.life += dt
        p.pos += p.vel * dt
        if p.life >= p.max_life{
            p.alive = false
        }
    }
}

update_loot :: proc(g : ^Game_State, dt : f32){
    for &l in g.loot{
        l.detection.pos = {l.pos.x + l.size.x/2, l.pos.y + l.size.y/2}
        l.pickup.pos = {l.pos.x + l.size.x/2, l.pos.y + l.size.y/2}
        if !l.is_active{
            l.time -= dt
            if l.time <= 0{
                l.is_active = true
                continue
            }
            l.pos += l.dir * l.speed * dt
        }
        if !l.is_following do continue
        dir := g.player.pos - l.pos
        dir = rl.Vector2Normalize(dir)

        if l.current_speed <= l.max_speed{
            l.current_speed += l.acceleration
        }

        l.pos += dir * l.current_speed * dt
    }
}

update_upgrade :: proc(g : ^Game_State, dt : f32){
    test := g.upgrade_menu.shader.test
    g.upgrade_menu.shader.timer -= dt
    if g.upgrade_menu.shader.timer <= 0{
        test += 0.1
        g.upgrade_menu.shader.timer = 0.5
    }
    color_test := rl.Vector4 {0.4, 0, 1, 0.5}
    rl.SetShaderValue(g.upgrade_menu.shader.bloom, g.upgrade_menu.shader.u_time_loc, &test, .FLOAT)
    rl.SetShaderValue(g.upgrade_menu.shader.bloom, g.upgrade_menu.shader.color_loc, &color_test, .VEC4)
    for &slot in g.upgrade_menu.upgrades{
        if slot.state == .Selected{
            on_upgrade(g, slot.upgrade)
            g.level_up = false
        }
    }
}

update_in_game_ui :: proc(g : ^Game_State, dt : f32){
    for &element in g.ui_elements{
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
        }
    }
}

update_menu :: proc(g : ^Game_State){
    for &element in g.menu.elements{
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
