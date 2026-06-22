package game

import "core:fmt"
import rl "vendor:raylib"

Dash_Data :: struct{
    dir : rl.Vector2,
    speed : f32,
    timer : f32,
    can_attack : bool,
    damage : f32,
    touched_enemies : [100]i32,
}

create_standard_dash :: proc() -> Ability{
    dash := Ability{
        cooldown_timer = {
            cast_rate = 3,
        },
        indicator = no_indicator_update,
        activate = dash_activate,
        update = dash_update,
        finish = dash_finish,
        draw = no_draw,
        
    }
    data := Dash_Data{
        speed = 3000,
        damage = 10,
    }

    for i in 0..<len(data.touched_enemies){
        data.touched_enemies[i] = -1
    }
    dash.data = data
    return dash
}

dash_activate :: proc(a : ^Ability, dt : f32){
    data := &game.player.ability.data.(Dash_Data)
    data.dir = game.player.vel
    if data.dir.x == 0 && data.dir.y == 0{
        mouse_pos := rl.GetMousePosition()
        mouse_local_pos := rl.GetScreenToWorld2D(mouse_pos, game.camera)
        data.dir = rl.Vector2Normalize(mouse_local_pos - game.player.pos)
        game.player.health.invincible_timer = 0.2
    }
    data.timer = 0.2
}

dash_update :: proc(a : ^Ability, dt : f32){
    data := &game.player.ability.data.(Dash_Data)
    if data.timer > 0{
        create_dash_particle(game.player.pos, data.dir)
        game.player.pos += data.dir * data.speed * dt

        if data.can_attack{
            for &e in game.level.enemies{
                confused := create_confused_status(500, 10)
                idx, ok := check_if_entity_already_got_status(e.statuses, confused)
                if rl.CheckCollisionCircleRec(game.player.pos, game.player.radius, e.rec) && !ok{
                    if is_enemy_already_touched(data.touched_enemies[:], &e) do continue
                    for i in 0..<len(data.touched_enemies){
                        if data.touched_enemies[i] != -1 do continue
                        data.touched_enemies[i] = e.id
                        break
                    }


                    // give_entity_status({confused}, &e)
                    // append(&e.statuses, confused)
                    // e.health->take_dmg(data.damage)
                }
            }
            
        }

        data.timer -= dt
        if game.player.ghost_timer > 0{
            game.player.ghost_timer -= dt
        } else{
            game.player.ghost_timer = Ghost_Time
            for i in 0..<len(game.player.ghosts){
                if game.player.ghosts[i].life > 0 do continue
                game.player.ghosts[i].pos = game.player.pos
                game.player.ghosts[i].life = 0.6
                break
            }
        }
    } else {
        a.state = .Finished
        // game.player.ability.active = false
        // dash_finish(a, dt)
    }
}

dash_finish :: proc(a : ^Ability, dt : f32){
    game.shake = 50

    data := &a.data.(Dash_Data)

    if !data.can_attack do return

    for i in 0..<len(data.touched_enemies){
        if data.touched_enemies[i] == -1 do continue
        e := get_enemy_by_id(data.touched_enemies[i])
        if e != nil{
            confused := create_confused_status(500, 2)
            e.health->take_dmg(data.damage)
            give_entity_status({confused}, e)
        }
        data.touched_enemies[i] = -1
    }
}

is_enemy_already_touched :: proc(touched_enemies : []i32, e : ^Enemy) -> bool{
    for i in 0..<len(touched_enemies){
        if touched_enemies[i] == -1 do continue
        if touched_enemies[i] == e.id do return true
    }
    return false
}

