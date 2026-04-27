package game

import "core:mem/virtual"
import "core:fmt"
import "core:mem"
import rl "vendor:raylib"
import "loot"
import "ui"
import m "map"

Level_Type :: enum{
    HQ, Battlefield, Forest
}

Level_Data :: struct{
    spawner : [dynamic]Spawner,
    enemies : [dynamic]Enemy,
    enemy_fragments : [dynamic]Enemy_Death_Fragment,
    enemy_bullets : [dynamic]Bullet,

    particles : [dynamic]Particle,

    npcs : [dynamic]NPC,

    player_bullets : [dynamic]Bullet,

    loot : [dynamic]loot.Shape_Shard,

    power_level_up : bool,
    upgrade_menu : UI_Upgrade_Menu,
    upgrade_pool : [dynamic]Upgrade,
    available_upgrades : [dynamic]Upgrade,

    ui_elements : [dynamic]ui.UI_Element,
    interact : ui.UI_Interact,
    level_visual : m.Tiled_Map,
}

create_level :: proc(type : Level_Type){
    rl.UnloadTexture(game.level.level_visual.texture)
    virtual.arena_destroy(&game.map_arena)
    err := virtual.arena_init_growing(&game.map_arena)
    game.map_allocator = virtual.arena_allocator(&game.map_arena)
    refresh_level()
    game.current_level = type
    switch type{
        case .HQ:
            create_start_level()     
        case .Battlefield:
            create_first_test_level()
        case .Forest:
    }
}

create_start_level :: proc(){
    npc := create_gunsmith_npc({100, 100})
    append(&game.level.npcs, npc)
    npc = create_commander_npc({0, 500})
    append(&game.level.npcs, npc)
    if level_visual, ok := m.load_map("assets/test_map.json", game.map_allocator); ok{
        game.player = create_player()
        game.player.pos = m.get_player_spawn_pos(level_visual)
        game.player.ability = Radial_Liberation{
            damage = 5,
            count = 8,
            ability_cd = {
                cast_rate = 5,
            },
        }
        game.camera.target = game.player.pos
        game.level.level_visual = level_visual
    } else{
        panic("Map could not load")
    }
}

create_first_test_level :: proc(){
    spawner := create_spawner(5, 0.5, 2)
    spawner.enemy = create_start_enemy({0, 0, 50, 40}, 200, rl.RED)
    append(&game.level.spawner, spawner)
    game.player.pos = {0, 0}
    create_battle_ui()
    level_up_spawner_update()
    if level_visual, ok := m.load_map("assets/test_map.json", game.map_allocator); ok{
        game.player.ability = Radial_Liberation{
            damage = 5,
            count = 8,
            ability_cd = {
                cast_rate = 5,
            }
        }
        get_upgrade_target()
        fill_available_upgrades()
        game.camera.target = game.player.pos
        game.level.level_visual = level_visual
    } else{
        panic("Map could not load")
    }
}

create_battle_ui :: proc(){
    rect := rl.Rectangle {
        x = 50,
        y = f32(rl.GetScreenHeight() - 100),
        width = f32(rl.GetScreenWidth()) * 0.25,
        height = 50,
    }
    p_bar := ui.create_progress_bar(rect, rl.BLACK, rl.GRAY, rl.RED)
    p_bar.show_text = true
    p_bar.min = 0
    p_bar.type = .Health

    v_bar := p_bar
    v_bar.rec.x += p_bar.rec.width + 60
    v_bar.fill_color = rl.BLUE
    v_bar.type = .Value
    append(&game.level.ui_elements, p_bar)
    append(&game.level.ui_elements, v_bar)

    a_cd := ui.UI_Cooldown{
        rec = {
            x = p_bar.rec.x + p_bar.rec.width + 5,
            y = p_bar.rec.y,
            width = p_bar.rec.height,
            height = p_bar.rec.height,
        },
    }
    append(&game.level.ui_elements, a_cd)



    pos : rl.Vector2 = {p_bar.rec.x, p_bar.rec.y - 25}
    status_bar := ui.create_ui_status_bar(pos)
    append(&game.level.ui_elements, status_bar)
}

create_choose_level :: proc(rec : rl.Rectangle, type : ^Level_Type) -> ui.UI_Button{
    test : ui.UI_Button
    text := fmt.tprintf("%v", type^)
    return ui.create_button(text, rec, on_click_change_level, type)
}

refresh_level :: proc(){
    clear(&game.level.npcs)
}