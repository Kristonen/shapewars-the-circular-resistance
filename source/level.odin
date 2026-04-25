package game

import "core:fmt"
import "core:mem"
import rl "vendor:raylib"
import "loot"
import "ui"
import m "map"

Level_Type :: enum{
    HQ, Battlefield
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
    skilltree : ui.UI_Skill_Tree,
}

create_level :: proc(type : Level_Type, allocator : mem.Allocator){
    switch type{
        case .HQ:
            create_start_level(allocator)        
        case .Battlefield:
    }
}

create_start_level :: proc(allocator : mem.Allocator){
    npc := create_gunsmith_npc({100, 100})
    append(&game.level.npcs, npc)
    npc = create_commander_npc({0, 500})
    append(&game.level.npcs, npc)
    if level_visual, ok := m.load_map("assets/test_map.json", allocator); ok{
        game.player = create_player()
        game.player.pos = m.get_player_spawn_pos(level_visual)
        game.camera.target = game.player.pos
        game.level.level_visual = level_visual
    } else{
        panic("Map could not load")
    }
}

create_choose_level :: proc(rec : rl.Rectangle, type : Level_Type) -> ui.UI_Button{
    test : ui.UI_Button
    text := fmt.tprintf("%v", type)
    return ui.create_button(text, rec, on_click_change_level, type)
}