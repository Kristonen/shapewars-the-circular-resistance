package game

import "base:builtin"
import "core:math"
import "core:strings"
import rl "vendor:raylib"
import "core:fmt"
import "collider"
import "ui"

Btn_Disabled_Color :: rl.Color{50, 50, 50, 255}

draw_player :: proc(){
    rl.DrawCircleV(game.player.pos, game.player.radius, rl.VIOLET)
    if game.player.ability.state == .Executing && game.player.current_ability == .Dash{
        rl.DrawCircleLinesV(game.player.pos, game.player.radius, rl.BLACK)
    }
    for i in 0..<len(game.player.ghosts){
        if game.player.ghosts[i].life <= 0 do continue
        black := rl.BLACK
        alpha := (game.player.ghosts[i].life/0.6)
        black.a = u8(alpha*255)
        rl.DrawCircleLinesV(game.player.ghosts[i].pos, game.player.radius, black)
    }

    draw_ability(game.player.ability)

    if game.helper_activated{
        draw_collider(game.player.physics_collider)
        draw_collider(game.player.hurt_collider)
        draw_collider(game.player.collector)
        draw_collider(game.player.loot_detector)
    }
}

draw_player_indicator :: proc(){
    if game.level.indicator == nil do return
    switch i in game.level.indicator{
        case AoE_Indicator:
            rl.DrawCircleV(i.pos, i.radius, {0, 0, 0, 100})
        case Line_Indicator:
    }
}

draw_npc :: proc(){
    for n in game.level.npcs{
        if n.state == .None do continue
        rl.DrawCircleV(n.pos, n.radius, n.texture)
        if game.helper_activated{
            draw_collider(n.interactable.collider)
        }
    }
}

draw_ability :: proc(a : Ability){
    if a.state == .Executing{
        a.draw(a)
    }
}

draw_map :: proc(){
    tileset_name := game.level.level_visual.tilesets[0].image
    tileset_path := fmt.tprintf("assets/%s", tileset_name)
    // texture := rl.LoadTexture(rl.TextFormat("%s", tileset_path))
    texture := game.level.level_visual.texture//rl.LoadTexture("assets/simple_tilemap_test.png")
    tiles_per_row := texture.width / i32(game.level.level_visual.tilewidth)

    for layer in game.level.level_visual.layers{
        if !layer.visible do continue

        if layer.type == "tilelayer"{
            for pos_y in 0..<game.level.level_visual.height{
                for pos_x in 0..<game.level.level_visual.width{
                    gid := layer.data[pos_y * game.level.level_visual.width + pos_x]
                    if gid == 0 do continue
                    id := i32(gid - 1)
                    
                    source := rl.Rectangle{
                        x = f32((id % tiles_per_row) * i32(game.level.level_visual.tilewidth)),
                        y = f32((id / tiles_per_row) * i32(game.level.level_visual.tileheight)),
                        width = f32(game.level.level_visual.tilewidth),
                        height = f32(game.level.level_visual.tileheight),
                    }

                    dest : rl.Vector2
                    dest.x = f32(pos_x * game.level.level_visual.tilewidth)
                    dest.y = f32(pos_y * game.level.level_visual.tileheight)

                    rl.DrawTextureRec(texture, source, dest, rl.WHITE)
                }
            }
        }

        if layer.type == "objectgroup" && layer.name == "Walls" && game.helper_activated {
            for obj in layer.objects{
                rect : rl.Rectangle = {
                    x = obj.x,
                    y = obj.y,
                    width = obj.width,
                    height = obj.height,
                }
                rl.DrawRectangleLinesEx(rect, 2, rl.RED)
            }
        }
    }
}

draw_bullet :: proc(){
    for b in game.level.player_bullets{
        rl.DrawCircleV(b.pos, b.radius, rl.RED)
        if game.helper_activated{
            draw_collider(b.collider)
        }
    }

    for b in game.level.enemy_bullets{
        rl.DrawCircleV(b.pos, b.radius, rl.RED)
        if game.helper_activated{
            draw_collider(b.collider)
        }
    }
}

draw_enemies :: proc(){
    for e in game.level.enemies{

        width := e.rec.width * e.visual_scale.x
        height := e.rec.height * e.visual_scale.y
        pos : rl.Vector2 = {e.rec.x, e.rec.y}
        if width != e.rec.width{
            pos.x -= (width - e.rec.width) / 2
            pos.y += (height - e.rec.height) / 2 
        }
        if e.hit_timer > 0{
            rl.DrawRectangleV(pos, {width, height}, rl.WHITE)
        } else{
                rl.DrawRectangleV(pos, {width, height}, e.color)
        }
        draw_progress_bar(e.health_bar)
        if game.helper_activated{
            draw_collider(e.collidor)
        }

        switch d in e.behavior{
            case Melee_Data:
            case Distance_Data:
            case Charge_Data:
            case Boss_Data:
                for a in d.abilities{
                    // if !s.active do break
                    if a.state == .None do continue
                    // if a.cast_visualizer.can_show do a.cast_visualizer.draw(e.origin)
                    if a.state == .Executing{
                        a.draw(a)
                    }
                }
        }

    }
}

draw_ability_projectiles :: proc(){
    for ap in game.level.ability_projectiles{
        ap.draw(ap)
    }
}

draw_portal :: proc(){
    if !game.level.portal.active do return
    // rl.DrawCircleV(game.level.portal.pos, game.level.portal.radius, rl.RED)
    // rl.DrawEllipse(i32(game.level.portal.pos.x), i32(game.level.portal.pos.y), game.level.portal.radius, game.level.portal.radius * 1.5, rl.RED)
    // rl.DrawTexture(game.level.portal.texture, i32(game.level.portal.pos.x), i32(game.level.portal.pos.y), rl.WHITE)
    pos := rl.Vector2{game.level.portal.pos.x, game.level.portal.pos.y}
    source_rec := get_animation_frame(game.level.portal.animation, 4)
    rl.DrawTexturePro(game.level.portal.texture, source_rec, {pos.x - 32, pos.y - 32, 64, 65}, {}, 0, rl.WHITE)
    if game.helper_activated{
        draw_collider(game.level.portal.interact.collider)
    }
}

draw_fragments :: proc(){
    for f in game.level.enemy_fragments{
        rl.DrawRectangleV({f.pos.x, f.pos.y}, {f.width, f.height}, f.color)
    }
}

draw_area_effects :: proc(){
    for &a in game.level.area_effects{
        rl.BeginShaderMode(game.dissolve.shader)
        current_time := f32(rl.GetTime())
        alpha := (a.duration/a.max_duration)
        color := rl.LIME
        color.a = u8(alpha*255)
        
        rl.SetShaderValue(game.dissolve.shader, game.dissolve.time_loc, &current_time, .FLOAT)
        rl.SetShaderValue(game.dissolve.shader, game.dissolve.radius_loc, &a.radius, .FLOAT)
        rl.SetShaderValue(game.dissolve.shader, game.dissolve.center_loc, &a.pos, .VEC2)

        rl.DrawCircleV(a.pos, a.radius, color)
        rl.EndShaderMode()
        
    }
}

draw_loot :: proc(){
    for l in game.level.loot{
        rl.DrawRectangleV({l.rec.x, l.rec.y}, {l.rec.width, l.rec.height}, l.color)
        // rl.DrawRectangleRec(l.rec, l.color)
        if game.helper_activated{
            draw_collider(l.pickup)
        }
    }
}

draw_chest :: proc(){
    rl.DrawCircleV(game.level.chest.pos, 24, game.level.chest.texture)
    if game.helper_activated{
        draw_collider(game.level.chest.interact.collider)
    }
}

draw_particles :: proc(){
    for p in game.level.particles{
        if p.state == .None do continue
        alpha := 1.0 - (p.life/p.max_life)
        color := p.color
        color.a = u8(alpha*255)

        switch p.type{
            case .Normal:
                rl.DrawCircleV(p.pos, p.size/2, color)
            case .Line:
                if rl.Vector2Length(p.vel) > 0.1{
                    line_end := p.pos - rl.Vector2Normalize(p.vel) * (p.size * 1.5)
                    color = rl.ColorAlphaBlend(rl.GOLD, p.color, color)
                    rl.DrawLineEx(p.pos, line_end, 3.0, color)
                }
            case .Expanding:
                rl.DrawCircleV(p.pos, p.size, color)
            case .PlasmaSmoke:
                mid_color := rl.ColorAlphaBlend(rl.RED, rl.ORANGE, color)
                final_color := rl.ColorAlphaBlend(rl.DARKGRAY, mid_color, color)
                rl.DrawCircleV(p.pos, 15, final_color)
        }
    }
}

draw_upgrade :: proc(){
    rl.DrawRectangleV({}, {game.level.upgrade_menu.width, game.level.upgrade_menu.height}, {0, 0, 0, 200})
    draw_glow_shader()
    for slot in game.level.upgrade_menu.upgrades{
        if slot.upgrade == nil do continue
        gray := rl.GRAY
        gray.a = 150
        if slot.state == .Focused{
            gray = {180, 180, 180, 150}
        }
        //Draw whole upgrade rec
        rl.DrawRectangleV({slot.rect.x, slot.rect.y}, {slot.rect.width, slot.rect.height}, gray)
        rl.DrawRectangleLinesEx(slot.rect, 1.5, slot.color)
        // draw_upgrade_shader()
        //Draw head of upgrade (name)
        rec := rl.Rectangle {slot.rect.x + 25, slot.rect.y + 100, slot.rect.width - 50, 50}
        rl.DrawRectangleV({rec.x, rec.y}, {rec.width, rec.height}, rl.BLACK)
        draw_better_text(slot.upgrade.name, rec)
        //Draw icon
        texture_rec := rec
        texture_rec.x = slot.rect.x + slot.rect.width/2 - 32
        texture_rec.y += rec.height + 50
        rl.DrawRectangleV({texture_rec.x, texture_rec.y}, {64, 64}, slot.color)
        //Draw desc rec of upgrade
        rec.y += 64 + 150
        rl.DrawRectangleV({rec.x, rec.y}, {rec.width, 200}, rl.BLACK)
        desc : string
        if slot.upgrade.max_used > 0{
            desc = fmt.tprintf("%v\n\n\tUsed: %i/%i", slot.upgrade.desc.content, slot.upgrade.count_used, slot.upgrade.max_used)
        } else {
            desc = fmt.tprintf("%v\n\n\tUsed: %i", slot.upgrade.desc.content, slot.upgrade.count_used)
        }
        
        // draw_text(desc, rec, 20)
        ui_desc := slot.upgrade.desc
        ui_desc.content = desc
        ui_desc.font_size = 20
        draw_better_text(ui_desc, rec)
        //Draw rarirty rec
        rec.y = slot.rect.y + slot.rect.height - 100
        rl.DrawRectangleV({rec.x, rec.y}, {rec.width, rec.height}, rl.BLACK)
        r_string := fmt.tprintf("%v", slot.upgrade.rarity)
        rarity_text := ui.UI_Text{
            content = r_string,
            font_size = 30,
            halign = .Center,
            valign = .Center,
            text_color = slot.color
        }
        draw_better_text(rarity_text, rec)
    }
}

draw_glow_shader :: proc(){
    rl.BeginBlendMode(.ADDITIVE)
        rl.BeginShaderMode(game.glow.shader)
            time := rl.GetTime()
            current_glow_intensity : f32
            current_glow_intensity = MIN_GLOW * f32(math.sin(time * GLOW_PULSE_SPEED)) * GLOW_AMPLITUDE
            // intensity : f32 = 0.1
            rl.SetShaderValue(game.glow.shader, game.glow.intensity_loc, &current_glow_intensity, .FLOAT)
            source := rl.Rectangle{0, 0, f32(game.fbo.texture.width), -f32(game.fbo.texture.height)}
            dest := rl.Rectangle{0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
            rl.DrawTexturePro(game.fbo.texture, source, dest, {0,0}, 0, rl.WHITE)
        rl.EndShaderMode()
    rl.EndBlendMode()
}

draw_in_game_ui :: proc(){
    for element in game.level.ui_elements{
        switch e in element{
            case ui.UI_Progress_Bar:
                if e.type == .Health{
                    draw_progress_bar(e)
                } else if e.type == .Value{
                    draw_progress_bar(e)
                }
            case ui.UI_Cooldown:
                draw_cooldown(e)
            case ui.UI_Button:
            case ui.UI_Menu:
            case ui.UI_Label:
            case ui.UI_Slider:
            case ui.UI_Status_Bar:
                draw_status_bar(e)
            case ui.UI_Panel:
        }
    }
    if !game.is_paused{
        draw_interact()
    }
    if game.current_level == .HQ do return
    rec := rl.Rectangle{
        x = f32(rl.GetScreenWidth() - 105),
        y = f32(rl.GetScreenHeight()) - 65,
        width = 100,
        height = 60,
    }
    text := ui.UI_Text{
        content = fmt.tprintf("Level: %i", game.player.loot_bag.level),
        font_size = 20,
        text_color = rl.WHITE,
        halign = .Center,
        valign = .Center,
    }
    draw_better_text(text, rec)

    if game.level.state == .Finished{
        rec.x = f32(rl.GetScreenWidth()/2) - 300
        rec.y = f32(rl.GetScreenHeight()) * 0.80
        rec.width = 600
        rec.height = 100
        text.content = "Press T to call the portal"
        text.font_size = 30
        draw_better_text(text, rec)
    }
}

draw_interact :: proc(){
    if game.level.interact.interactable == nil do return
    draw_better_text(game.level.interact.text, game.level.interact.rec)
}

draw_progress_bar :: proc(bar : ui.UI_Progress_Bar){
    b_bar, f_bar := ui.get_health_bars(bar, 2.0)
    rl.DrawRectangleV({bar.rec.x, bar.rec.y}, {bar.rec.width, bar.rec.height}, bar.outline_color)
    rl.DrawRectangleV({b_bar.x, b_bar.y}, {b_bar.width, b_bar.height}, bar.background_color)
    rl.DrawRectangleV({f_bar.x, f_bar.y}, {f_bar.width, f_bar.height}, bar.fill_color)

    if bar.show_text{
        content := fmt.tprintf("%0.f/%0.f", bar.value, bar.max);
        text := ui.UI_Text{
            content = content,
            valign = .Center,
            halign = .Center,
            font_size = 30,
            text_color = rl.WHITE,
        }
        draw_better_text(text, bar.rec)
    }
}

draw_cooldown :: proc(cd : ui.UI_Cooldown){
    // rl.DrawRectangleV({cd.rec.x, cd.rec.y}, {cd.rec.width, cd.rec.height}, rl.BLACK)
    // rl.DrawRectangleRec(cd.rec, rl.BLACK)
    // color := rl.Color{255, 255, 255, 100}
    // height := cd.rec.height * (cd.value/cd.max)
    // rl.DrawRectangleV({cd.rec.x, cd.rec.y}, {cd.rec.width, height}, color)
    // rl.DrawRectangleRec(cd.rec, color)

    progress := cd.value / cd.max

    rl.SetShaderValue(game.cd_shader.shader, game.cd_shader.progress_loc, &progress, .FLOAT)
    rl.BeginShaderMode(game.cd_shader.shader)
    rl.DrawRectangleRec(cd.rec, rl.BLACK)
    rl.EndShaderMode()
}

draw_collider :: proc{
    draw_collider_circle,
    draw_collider_rect,
}

draw_collider_circle :: proc(c : collider.Collider_Circle){
    color := rl.GREEN
    color.a = 100
    rl.DrawCircleV(c.pos, c.radius, color)
}

draw_collider_rect :: proc(c : collider.Collider_Rectangle){
    color := rl.GREEN
    color.a = 100
    rl.DrawRectangleV({c.rec.x, c.rec.y}, {c.rec.width, c.rec.height}, color)
}

draw_text :: proc(text : string, r : rl.Rectangle, font_size : i32 = 30, color : rl.Color = rl.WHITE){
    ctext := strings.clone_to_cstring(text)
    text_width := rl.MeasureText(ctext, font_size)
    text_height : i32 = font_size
    text_x := i32(r.x) + (i32(r.width) - text_width) / 2
    text_y := i32(r.y) + (i32(r.height) - text_height) / 2
    rl.DrawText(ctext, text_x, text_y, font_size, color)
    delete(ctext)
}

draw_better_text :: proc(t : ui.UI_Text, rec : rl.Rectangle){
    ctext := strings.clone_to_cstring(t.content)
    text_width := rl.MeasureText(ctext, t.font_size)
    text_height : i32 = t.font_size
    //
    text_x : i32
    text_y : i32
    switch t.valign{
        case .Left:
            text_x = i32(rec.x) + 10
        case .Center:
            text_x = i32(rec.x) + (i32(rec.width) - text_width) / 2
        case .Right:
            text_x = i32(rec.x + rec.width) - text_width - 10
    }

    switch t.halign{
        case .Top:
            text_y = i32(rec.y) + 10
        case .Center:
            text_y = i32(rec.y) + (i32(rec.height) - text_height) / 2
        case .Bottom:
            text_y = i32(rec.y + rec.height) - text_height - 10
    }
    other_text := t
    wrap_text_to_rec(&other_text, rec, {f32(text_x), f32(text_y)})
    draw_ctext := strings.clone_to_cstring(other_text.content)
    rl.DrawText(draw_ctext, text_x, text_y, t.font_size, t.text_color)
    delete(ctext)
    delete(draw_ctext)
}

wrap_text_to_rec :: proc(t : ^ui.UI_Text, rec : rl.Rectangle, text_start : rl.Vector2){
// 1. Use temp memory so we don't leak strings every frame
    // builder := strings.make_builder(context.temp_allocator)
    builder : strings.Builder
    strings.builder_init(&builder, context.temp_allocator)
    
    // 2. Split the text into individual words
    words := strings.split(t.content, " ", context.temp_allocator)
    
    current_line_width: f32 = 0
    space_width := f32(rl.MeasureText(" ", t.font_size))

    for word, i in words {
        // Measure the word
        word_width := f32(rl.MeasureText(strings.clone_to_cstring(word, context.temp_allocator), t.font_size))

        // 3. If word doesn't fit, move to next line
        if current_line_width + word_width > rec.width {
            strings.write_string(&builder, "\n")
            current_line_width = 0
        }

        // 4. Write the word
        strings.write_string(&builder, word)
        current_line_width += word_width

        // Add a space back if it's not the last word of the original text
        if i < len(words) - 1 {
            strings.write_string(&builder, " ")
            current_line_width += space_width
        }
    }

    // Assign the newly formatted string back to the text component
    t.content = strings.to_string(builder)
    strings.builder_destroy(&builder)
}

draw_menu :: proc(){
    rl.DrawRectangleV({0, 0}, {game.menu.width, game.menu.height}, game.menu.color)
    for element in game.menu.elements{
        switch e in element{
            case ui.UI_Panel:
                draw_panel(e)
            case ui.UI_Cooldown:
            case ui.UI_Button:
                draw_button(e)
            case ui.UI_Menu:
            case ui.UI_Progress_Bar:
            case ui.UI_Label:
                draw_label(e)
            case ui.UI_Slider:
                draw_slider(e)
            case ui.UI_Status_Bar:
        } 
    }
}

draw_panel :: proc(p : ui.UI_Panel){
    rl.DrawRectangleRec(p.rec, p.color)
}

draw_skilltree :: proc(){
    type := fmt.tprintf("%v", game.active_skilltree)

    for l in game.skilltrees[type].lines{
        from := game.skilltrees[type].nodes[l.from_idx]
        to := game.skilltrees[type].nodes[l.to_idx]
        pos := from.pos
        if from.count != 0{
            progress := f32(from.count)/f32(to.needed_count)
            total_dist := rl.Vector2Distance(from.pos, to.pos)
            dir := to.pos - from.pos
            dir = rl.Vector2Normalize(dir)
            pos = from.pos + (dir * total_dist * progress)
            if total_dist < rl.Vector2Distance(pos, from.pos){
                pos = to.pos
            }
        }
        
        rl.DrawLineEx(from.pos, to.pos, 2.5, {100, 100, 100, 255})
        rl.DrawLineEx(from.pos, pos, 2.5, {255, 255, 255, 255})
    }
    
    for n in game.skilltrees[type].nodes{
        color : rl.Color
        r : f32
        pos := rl.Vector2 {n.pos.x, n.pos.y}
        if n.state == .None{
            r = n.radius
        } else if n.state == .Focussed{
            r = n.radius * 1.5
        }
        if n.is_active{
            color = {255, 255, 255, 255}
        } else{
            color = {150, 150, 150, 255}
        }
        rl.DrawCircleV(pos, r, color)
        rec := rl.Rectangle{
            x = n.pos.x - 20,
            y = n.pos.y + 25,
            width = 40,
            height = 50,
        }
        draw_better_text(n.used, rec)
        if n.state == .Focussed{
            draw_skilltree_desc(n.name, n.desc)
        }
    }

    rec := rl.Rectangle{
        x = f32(rl.GetScreenWidth()/2 - 250),
        y = 5,
        width = 500,
        height = 100,
    }
    text := ui.UI_Text{
        content = fmt.tprintf("Available skill points: %i", game.skill_points),
        font_size = 30,
        text_color = rl.WHITE,
        halign = .Center,
        valign = .Center,
    }
    draw_better_text(text, rec)
}

draw_skilltree_desc :: proc(n : ui.UI_Text, desc : ui.UI_Text){
    rec := rl.Rectangle{
        x = f32(rl.GetScreenWidth() - 500),
        y = f32(rl.GetScreenHeight() - 300),
        width = 500,
        height = 100,
    }
    rl.DrawRectangleLinesEx(rec, 5, rl.WHITE)
    draw_better_text(n, rec)
    rec.y += 95
    rec.height = 200
    rl.DrawRectangleLinesEx(rec, 5, rl.WHITE)
    draw_better_text(desc, rec)
}

draw_button :: proc(b : ui.UI_Button){
    if !b.show do return
    color := b.disabled ? Btn_Disabled_Color : b.color
    rl.DrawRectangleRec(b.rec, color)
    rl.DrawRectangleLinesEx(b.rec, 5, rl.BLACK)
    draw_better_text(b.text, b.rec)

    if (b.state == .Focus || b.state == .Pressing || b.state == .Pressed) && (game.current_menu == .EquiptmentBullet || game.current_menu == .EquiptmentAbility){
        switch type in b.data{
            case Unlocked_Data_Type:
                x := f32(rl.GetScreenWidth())*0.75
                y : f32 = 0
                rl.DrawLineEx({x, y}, {x, f32(rl.GetScreenHeight())}, 5, rl.WHITE)
                text := ui.UI_Text{
                    content = get_text_for_unlocked(type),
                    font_size = 30,
                    text_color = rl.WHITE,
                    halign = .Top,
                    valign = .Left,
                }
                rec := rl.Rectangle{x = x, y = y, width = f32(rl.GetScreenWidth()) - x, height = f32(rl.GetScreenHeight())}
                draw_better_text(text, rec)
        }
    }

    if game.current_menu == .Craftman && b.text.content == "Buy"{
        switch type in b.data{
            case Unlocked_Data_Type:
                x := f32(rl.GetScreenWidth()) * 0.3
                y : f32 = 0
                rl.DrawLineEx({x, y}, {x, f32(rl.GetScreenHeight())/2}, 5, rl.WHITE)
                rec := rl.Rectangle{
                    x = x + 5,
                    y = 5,
                    width = 500,
                    height = 500,
                }
                t := ui.UI_Text{
                    content = get_text_for_craftable(type),
                    font_size = 25,
                    text_color = rl.WHITE,
                    halign = .Top,
                    valign = .Left,
                }
                draw_better_text(t, rec)
                rec.x = f32(rl.GetScreenWidth())/2 - 200
                rec.y = f32(rl.GetScreenHeight()) - 205
                rec.width = 400
                rec.height = 200
                t.content = fmt.tprintf("Shards: %0.0f", game.shards)
                draw_better_text(t, rec)
                
        }
        refresh_ui_pointers()
    }
}

draw_label :: proc(l : ui.UI_Label){
    rl.DrawRectangleV({l.rec.x, l.rec.y}, {l.rec.width, l.rec.height}, l.color)
    rl.DrawRectangleLinesEx(l.rec, 5, rl.BLACK)
    draw_better_text(l.text, l.rec)
}

draw_slider :: proc(s : ui.UI_Slider){
    end_pos := rl.Vector2{
        s.rec.x + s.rec.width, s.rec.y
    }
    // rl.DrawLineV(s.pos, end_pos, rl.BLACK)
    rl.DrawLineEx({s.rec.x, s.rec.y}, end_pos, 5, rl.BLACK)
    rl.DrawRectangleV({s.slider.x, s.slider.y}, {s.slider.width, s.slider.height}, s.color)
}

draw_status_bar :: proc(sbar : ui.UI_Status_Bar){
    for slot in sbar.slots{
        rl.DrawRectangleV({slot.rec.x, slot.rec.y}, {slot.rec.width, slot.rec.height}, slot.texture)
    }
}

draw_tooltip :: proc(){
    if game.tooltip_ptr == nil do return
    if game.tooltip_timer > 0 do return

    rl.DrawRectangleV({game.tooltip.rec.x, game.tooltip.rec.y}, 
        {game.tooltip.rec.width, game.tooltip.rec.height}, game.tooltip.color)
    draw_text(game.tooltip.text.content, game.tooltip.rec, game.tooltip.text.font_size, game.tooltip.text.text_color)
}