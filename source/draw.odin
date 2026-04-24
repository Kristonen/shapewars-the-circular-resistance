package game

import "core:strings"
import rl "vendor:raylib"
import "core:fmt"
import "collider"
import "ui"

draw_player :: proc(){
    rl.DrawCircleV(game.player.pos, game.player.radius, rl.VIOLET)
    if game.helper_activated{
        draw_collider_circle(game.player.physics_collider)
        draw_collider_circle(game.player.hurt_collider)
        draw_collider_circle(game.player.collector)
    }
}

draw_npc :: proc(){
    for n in game.current_level.npcs{
        rl.DrawCircleV(n.pos, n.radius, n.texture)
        if game.helper_activated{
            draw_collider_circle(n.interactable.collider)
        }
    }
}

draw_map :: proc(){
    tileset_name := game.current_level.level_visual.tilesets[0].image
    tileset_path := fmt.tprintf("assets/%s", tileset_name)
    // texture := rl.LoadTexture(rl.TextFormat("%s", tileset_path))
    texture := game.current_level.level_visual.texture//rl.LoadTexture("assets/simple_tilemap_test.png")
    tiles_per_row := texture.width / i32(game.current_level.level_visual.tilewidth)

    for layer in game.current_level.level_visual.layers{
        if !layer.visible do continue

        if layer.type == "tilelayer"{
            for pos_y in 0..<game.current_level.level_visual.height{
                for pos_x in 0..<game.current_level.level_visual.width{
                    gid := layer.data[pos_y * game.current_level.level_visual.width + pos_x]
                    if gid == 0 do continue
                    id := i32(gid - 1)
                    
                    source := rl.Rectangle{
                        x = f32((id % tiles_per_row) * i32(game.current_level.level_visual.tilewidth)),
                        y = f32((id / tiles_per_row) * i32(game.current_level.level_visual.tileheight)),
                        width = f32(game.current_level.level_visual.tilewidth),
                        height = f32(game.current_level.level_visual.tileheight),
                    }

                    dest : rl.Vector2
                    dest.x = f32(pos_x * game.current_level.level_visual.tilewidth)
                    dest.y = f32(pos_y * game.current_level.level_visual.tileheight)

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
    for b in game.current_level.player_bullets{
        rl.DrawCircleV(b.pos, b.radius, rl.RED)
        if game.helper_activated{
            draw_collider_circle(b.collider)
        }
    }

    for b in game.current_level.enemy_bullets{
        rl.DrawCircleV(b.pos, b.radius, rl.RED)
        if game.helper_activated{
            draw_collider_circle(b.collider)
        }
    }
}

draw_enemies :: proc(){
    for e in game.current_level.enemies{
        width := e.rec.width * e.visual_scale.x
        height := e.rec.height * e.visual_scale.y
        pos : rl.Vector2 = {e.rec.x, e.rec.y}
        if width != e.rec.width{
            pos.x -= (width - e.rec.width) / 2
            pos.y += (height - e.rec.height) / 2 
        }
        rl.DrawRectangleV(pos, {width, height}, e.color)
        draw_progress_bar(e.health_bar)
        if game.helper_activated{
            draw_collider_rect(e.collidor)
        }
    }
}

draw_fragments :: proc(){
    for f in game.current_level.enemy_fragments{
        rl.DrawRectangleV({f.pos.x, f.pos.y}, {f.width, f.height}, f.color)
    }
}

draw_loot :: proc(){
    for l in game.current_level.loot{
        rl.DrawRectangleV({l.rec.x, l.rec.y}, {l.rec.width, l.rec.height}, l.color)
        // rl.DrawRectangleRec(l.rec, l.color)
        if game.helper_activated{
            draw_collider_circle(l.detection)
            draw_collider_circle(l.pickup)
        }
    }
}

draw_particles :: proc(){
    for p in game.current_level.particles{
        alpha := 1.0 - (p.life/p.max_life)
        color := p.color
        color.a = u8(alpha*255)
        rl.DrawCircleV(p.pos, p.size/2, color)
    }
}

draw_upgrade :: proc(){
    rl.DrawRectangleV({}, {game.current_level.upgrade_menu.width, game.current_level.upgrade_menu.height}, {0, 0, 0, 200})
    for slot in game.current_level.upgrade_menu.upgrades{
        gray := rl.GRAY
        gray.a = 150
        if slot.state == .Focused{
            gray = {180, 180, 180, 150}
        }
        //Draw whole upgrade rec
        rl.DrawRectangleV({slot.rect.x, slot.rect.y}, {slot.rect.width, slot.rect.height}, gray)
        rl.DrawRectangleLinesEx(slot.rect, 5, slot.color)
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
        // draw_text(r_string, rec, 20, slot.color)
    }
}

draw_in_game_ui :: proc(){
    for element in game.current_level.ui_elements{
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
            case ui.UI_Skill_Tree:
        }
    }
    if !game.is_paused{
        draw_interact()
    }
}

draw_interact :: proc(){
    if game.current_level.interact.interactable == nil do return
    draw_better_text(game.current_level.interact.text, game.current_level.interact.rec)
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
    rl.DrawRectangleV({cd.rec.x, cd.rec.y}, {cd.rec.width, cd.rec.height}, rl.BLACK)
    color := rl.Color{255, 255, 255, 100}
    height := cd.rec.height * (cd.value/cd.max)
    rl.DrawRectangleV({cd.rec.x, cd.rec.y}, {cd.rec.width, height}, color)
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
            case ui.UI_Skill_Tree:
                draw_skilltree(e)
        } 
    }
}

draw_skilltree :: proc(st : ui.UI_Skill_Tree){
    for l in st.lines{
        from := st.nodes[l.from_idx]
        to := st.nodes[l.to_idx]
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
    
    for n in st.nodes{
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
    rl.DrawRectangleV({b.rec.x, b.rec.y}, {b.rec.width, b.rec.height}, b.color)
    rl.DrawRectangleLinesEx(b.rec, 5, rl.BLACK)
    draw_better_text(b.text, b.rec)
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