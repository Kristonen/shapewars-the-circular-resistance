package game

import "core:strings"
import rl "vendor:raylib"
import "core:fmt"
import "collider"
import "ui"

draw_player :: proc(g : Game_State){
    rl.DrawCircleV(g.player.pos, g.player.radius, rl.VIOLET)
    if g.helper_activated{
        draw_collider_circle(g.player.collider)
    }
}

draw_map :: proc(g : Game_State){
    tileset_name := g.current_level.level_visual.tilesets[0].image
    tileset_path := fmt.tprintf("assets/%s", tileset_name)
    // texture := rl.LoadTexture(rl.TextFormat("%s", tileset_path))
    texture := g.current_level.level_visual.texture//rl.LoadTexture("assets/simple_tilemap_test.png")
    tiles_per_row := texture.width / i32(g.current_level.level_visual.tilewidth)

    for layer in g.current_level.level_visual.layers{
        if !layer.visible do continue

        if layer.type == "tilelayer"{
            for pos_y in 0..<g.current_level.level_visual.height{
                for pos_x in 0..<g.current_level.level_visual.width{
                    gid := layer.data[pos_y * g.current_level.level_visual.width + pos_x]
                    if gid == 0 do continue
                    id := i32(gid - 1)
                    
                    source := rl.Rectangle{
                        x = f32((id % tiles_per_row) * i32(g.current_level.level_visual.tilewidth)),
                        y = f32((id / tiles_per_row) * i32(g.current_level.level_visual.tileheight)),
                        width = f32(g.current_level.level_visual.tilewidth),
                        height = f32(g.current_level.level_visual.tileheight),
                    }

                    dest : rl.Vector2
                    dest.x = f32(pos_x * g.current_level.level_visual.tilewidth)
                    dest.y = f32(pos_y * g.current_level.level_visual.tileheight)

                    rl.DrawTextureRec(texture, source, dest, rl.WHITE)
                }
            }
        }

        if layer.type == "objectgroup" && layer.name == "Walls" && g.helper_activated {
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

draw_bullet :: proc(g : Game_State){
    for b in g.current_level.player_bullets{
        rl.DrawCircleV(b.pos, b.radius, rl.RED)
        if g.helper_activated{
            draw_collider_circle(b.collider)
        }
    }

    for b in g.current_level.enemy_bullets{
        rl.DrawCircleV(b.pos, b.radius, rl.RED)
        if g.helper_activated{
            draw_collider_circle(b.collider)
        }
    }
}

draw_enemies :: proc(g : Game_State){
    for e in g.current_level.enemies{
        width := e.rec.width * e.visual_scale.x
        height := e.rec.height * e.visual_scale.y
        pos : rl.Vector2 = {e.rec.x, e.rec.y}
        if width != e.rec.width{
            pos.x -= (width - e.rec.width) / 2
            pos.y += (height - e.rec.height) / 2 
        }
        rl.DrawRectangleV(pos, {width, height}, e.color)
        draw_progress_bar(e.health_bar)
        if g.helper_activated{
            draw_collider_rect(e.collidor)
        }
    }
}

draw_fragments :: proc(g : Game_State){
    for f in g.current_level.enemy_fragments{
        rl.DrawRectangleV({f.pos.x, f.pos.y}, {f.width, f.height}, f.color)
    }
}

draw_loot :: proc(g : Game_State){
    for l in g.current_level.loot{
        rl.DrawRectangleV({l.rec.x, l.rec.y}, {l.rec.width, l.rec.height}, l.color)
        // rl.DrawRectangleRec(l.rec, l.color)
        if g.helper_activated{
            draw_collider_circle(l.detection)
            draw_collider_circle(l.pickup)
        }
    }
}

draw_particles :: proc(g : Game_State){
    for p in g.current_level.particles{
        alpha := 1.0 - (p.life/p.max_life)
        color := p.color
        color.a = u8(alpha*255)
        rl.DrawCircleV(p.pos, p.size/2, color)
    }
}

draw_upgrade :: proc(g : Game_State){
    rl.DrawRectangleV({}, {g.current_level.upgrade_menu.width, g.current_level.upgrade_menu.height}, {0, 0, 0, 200})
    for slot in g.current_level.upgrade_menu.upgrades{
        gray := rl.GRAY
        gray.a = 150
        if slot.state == .Focused{
            gray = {180, 180, 180, 150}
        }
        rl.DrawRectangleV({slot.rect.x, slot.rect.y}, {slot.rect.width, slot.rect.height}, gray)
        rl.DrawRectangleLinesEx(slot.rect, 5, slot.color)

        rect := rl.Rectangle {slot.rect.x + 25, slot.rect.y + 100, slot.rect.width - 50, 50}
        rl.DrawRectangleV({rect.x, rect.y}, {rect.width, rect.height}, rl.BLACK)
        draw_text(slot.upgrade.name, rect)

        texture_rect := rect
        texture_rect.x = slot.rect.x + slot.rect.width/2 - 32
        texture_rect.y += rect.height + 50
        rl.DrawRectangleV({texture_rect.x, texture_rect.y}, {64, 64}, slot.color)
        rect.y += 64 + 150
        rl.DrawRectangleV({rect.x, rect.y}, {rect.width, 200}, rl.BLACK)
        desc : string
        if slot.upgrade.max_used > 0{
            desc = fmt.tprintf("%v\n\n\tUsed: %i/%i", slot.upgrade.desc, slot.upgrade.count_used, slot.upgrade.max_used)
        } else {
            desc = fmt.tprintf("%v\n\n\tUsed: %i", slot.upgrade.desc, slot.upgrade.count_used)
        }
        
        draw_text(desc, rect, 20)
        rect.y = slot.rect.y + slot.rect.height - 100
        rl.DrawRectangleV({rect.x, rect.y}, {rect.width, rect.height}, rl.BLACK)
        r_string := fmt.tprintf("%v", slot.upgrade.rarity)
        draw_text(r_string, rect, 20, slot.color)
    }
}

draw_in_game_ui :: proc(g : Game_State){
    for element in g.current_level.ui_elements{
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
        }
    }
}

draw_progress_bar :: proc(bar : ui.UI_Progress_Bar){
    b_bar, f_bar := ui.get_health_bars(bar, 2.0)
    rl.DrawRectangleV({bar.rec.x, bar.rec.y}, {bar.rec.width, bar.rec.height}, bar.outline_color)
    rl.DrawRectangleV({b_bar.x, b_bar.y}, {b_bar.width, b_bar.height}, bar.background_color)
    rl.DrawRectangleV({f_bar.x, f_bar.y}, {f_bar.width, f_bar.height}, bar.fill_color)

    if bar.show_text{
        text := fmt.tprintf("%0.f/%0.f", bar.value, bar.max);
        draw_text(text, bar.rec)
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
    rl.DrawText(ctext, i32(text_x), i32(text_y), font_size, color)
    delete(ctext)
}

draw_menu :: proc(g : Game_State){
    rl.DrawRectangleV({0, 0}, {g.menu.width, g.menu.height}, g.menu.color)
    for element in g.menu.elements{
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
        } 
    }
}

draw_button :: proc(b : ui.UI_Button){
    rl.DrawRectangleV({b.rec.x, b.rec.y}, {b.rec.width, b.rec.height}, b.color)
    rl.DrawRectangleLinesEx(b.rec, 5, rl.BLACK)
    draw_text(b.text, b.rec)
}

draw_label :: proc(l : ui.UI_Label){
    rl.DrawRectangleV({l.rec.x, l.rec.y}, {l.rec.width, l.rec.height}, l.color)
    rl.DrawRectangleLinesEx(l.rec, 5, rl.BLACK)
    draw_text(l.text, l.rec)
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
    draw_text(game.tooltip.text.text, game.tooltip.rec, game.tooltip.text.font_size, game.tooltip.text.text_color)
}