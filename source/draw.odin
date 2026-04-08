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
    tileset_name := g.level.tilesets[0].image
    tileset_path := fmt.tprintf("assets/%s", tileset_name)
    // texture := rl.LoadTexture(rl.TextFormat("%s", tileset_path))
    texture := g.level.texture//rl.LoadTexture("assets/simple_tilemap_test.png")
    tiles_per_row := texture.width / i32(g.level.tilewidth)

    for layer in g.level.layers{
        if !layer.visible do continue

        if layer.type == "tilelayer"{
            for pos_y in 0..<g.level.height{
                for pos_x in 0..<g.level.width{
                    gid := layer.data[pos_y * g.level.width + pos_x]
                    if gid == 0 do continue
                    id := i32(gid - 1)
                    
                    source := rl.Rectangle{
                        x = f32((id % tiles_per_row) * i32(g.level.tilewidth)),
                        y = f32((id / tiles_per_row) * i32(g.level.tileheight)),
                        width = f32(g.level.tilewidth),
                        height = f32(g.level.tileheight),
                    }

                    dest : rl.Vector2
                    dest.x = f32(pos_x * g.level.tilewidth)
                    dest.y = f32(pos_y * g.level.tileheight)

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
    for b in g.player_bullets{
        rl.DrawCircleV(b.pos, b.radius, rl.RED)
        if g.helper_activated{
            draw_collider_circle(b.collider)
        }
    }
}

draw_enemies :: proc(g : Game_State){
    for e in g.enemies{
        rl.DrawRectangleV(e.pos, {e.width, e.height}, rl.RED)
        draw_progress_bar(e.health_bar)
        if g.helper_activated{
            draw_collider_rect(e.collidor)
        }
    }
}

draw_loot :: proc(g : Game_State){
    for l in g.loot{
        rl.DrawRectangleV(l.pos, l.size, l.color)
        if g.helper_activated{
            draw_collider_circle(l.detection)
            draw_collider_circle(l.pickup)
        }
    }
}

draw_particles :: proc(g : Game_State){
    for p in g.particles{
        alpha := 1.0 - (p.life/p.max_life)
        color := p.color
        color.a = u8(alpha*255)
        rl.DrawCircleV(p.pos, p.size/2, color)
    }
}

draw_in_game_ui :: proc(g : Game_State){
    for element in g.ui_elements{
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
        }
    }
}

draw_progress_bar :: proc(bar : ui.UI_Progress_Bar){
    b_bar, f_bar := ui.get_health_bars(bar, 2.0)
    rl.DrawRectangleV({bar.rect.x, bar.rect.y}, {bar.rect.width, bar.rect.height}, bar.outline_color)
    rl.DrawRectangleV({b_bar.x, b_bar.y}, {b_bar.width, b_bar.height}, bar.background_color)
    rl.DrawRectangleV({f_bar.x, f_bar.y}, {f_bar.width, f_bar.height}, bar.fill_color)

    if bar.show_text{
        text := fmt.tprintf("%0.f/%0.f", bar.value, bar.max);
        draw_text(text, bar.rect)
    }
}

draw_cooldown :: proc(cd : ui.UI_Cooldown){
    rl.DrawRectangleV({cd.pos.x, cd.pos.y}, {cd.width, cd.height}, rl.BLACK)
    color := rl.Color{255, 255, 255, 100}
    height := cd.height * (cd.value/cd.max)
    rl.DrawRectangleV({cd.pos.x, cd.pos.y}, {cd.width, height}, color)
}

draw_collider_circle :: proc(c : collider.Collider_Circle){
    color := rl.GREEN
    color.a = 100
    rl.DrawCircleV(c.pos, c.radius, color)
}

draw_collider_rect :: proc(c : collider.Collider_Rectangle){
    color := rl.GREEN
    color.a = 100
    rl.DrawRectangleV(c.pos, {c.width, c.height}, color)
}

draw_text :: proc(text : string, r : rl.Rectangle){
    font_size : i32 = 30
    ctext := strings.clone_to_cstring(text)
    text_width := rl.MeasureText(ctext, font_size)
    text_height : i32 = font_size
    text_x := i32(r.x) + (i32(r.width) - text_width) / 2
    text_y := i32(r.y) + (i32(r.height) - text_height) / 2
    rl.DrawText(ctext, i32(text_x), i32(text_y), font_size, rl.WHITE)
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
        } 
    }
}

draw_button :: proc(b : ui.UI_Button){
    rect := rl.Rectangle{
        x = b.pos.x,
        y = b.pos.y,
        width = b.width,
        height = b.height,
    }
    rl.DrawRectangleV(b.pos, {b.width, b.height}, b.color)
    rl.DrawRectangleLinesEx(rect, 5, rl.BLACK)
    draw_text(b.text, rect)
}

draw_label :: proc(l : ui.UI_Label){
    rl.DrawRectangleV(l.pos, {l.width, l.height}, l.color)
    rl.DrawRectangleLinesEx({l.pos.x, l.pos.y, l.width, l.height}, 5, rl.BLACK)
    draw_text(l.text, {l.pos.x, l.pos.y, l.width, l.height})
}

draw_slider :: proc(s : ui.UI_Slider){
    end_pos := rl.Vector2{
        s.pos.x + s.width, s.pos.y
    }
    // rl.DrawLineV(s.pos, end_pos, rl.BLACK)
    rl.DrawLineEx(s.pos, end_pos, 5, rl.BLACK)
    rl.DrawRectangleV({s.slider.x, s.slider.y}, {s.slider.width, s.slider.height}, s.color)
}