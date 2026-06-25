package game

import "core:mem/virtual"
import "core:fmt"
import "core:mem"
import rl "vendor:raylib"
import "ui"
import m "map"

Level_Type :: enum{
    HQ, Battlefield, Forest, Test, Boss_Test
}

Level_State :: enum{
    Ongoing, Finished
}

Level_Data :: struct{
    spawner : [25]Spawner,
    enemies : [500]Enemy,
    enemy_fragments : [dynamic]Enemy_Death_Fragment,
    enemy_bullets : [dynamic]Bullet,
    area_effects : [dynamic]Area_Effect,
    indicator : Indicator,

    particles : [500]Particle,

    npcs : [10]NPC,

    player_bullets : [500]Bullet,

    ability_projectiles : [dynamic]Ability_Projectile,

    loot : [250]Loot,
    chest : Chest,

    portal : Portal,

    power_level_up : bool,
    upgrade_menu : UI_Upgrade_Menu,
    upgrade_pool : [dynamic]Upgrade,
    available_upgrades : [dynamic]Upgrade,

    ui_elements : [dynamic]ui.UI_Element,
    interact : ui.UI_Interact,
    level_visual : m.Tiled_Map,
    state : Level_State,
}

create_level :: proc(type : Level_Type){
    rl.UnloadTexture(game.level.level_visual.texture)
    virtual.arena_destroy(&game.map_arena)
    err := virtual.arena_init_growing(&game.map_arena)
    game.map_allocator = virtual.arena_allocator(&game.map_arena)
    refresh_level()
    refresh_player()

    if game.current_level != .HQ{
        game.shards += game.player.loot_bag.full_value
        fill_available_upgrades()
    }

    reset_loot_bag(&game.player.loot_bag)
    game.current_level = type
    switch type{
        case .HQ:
            create_start_level()     
        case .Battlefield:
            create_first_test_level()
        case .Forest:
        case .Test:
            create_test_level()
        case .Boss_Test:
            create_boss_test_level()

    }
}

refresh_player :: proc(){
    game.player.health.max = 100
    game.player.health.current = 100
    game.player.health.is_dead = false
    game.player.loot_detector.radius = game.player.radius * 4
    clear(&game.player.weapon.bullet.hitted_enemies)
    switch_weapon()
    switch_ability()
}

create_start_level :: proc(){
    npc := create_gunsmith_npc({100, 100})
    add_entity_to_game(&npc)
    npc = create_commander_npc({0, 500})
    add_entity_to_game(&npc)
    npc = create_catalyst_npc({400, -200})
    add_entity_to_game(&npc)
    npc = create_quartermaster_npc({400, 400})
    add_entity_to_game(&npc)
    npc = create_craftman_npc({325, 250})
    add_entity_to_game(&npc)
    if level_visual, ok := m.load_map("assets/test_map.json", game.map_allocator); ok{
        game.player.pos = m.get_player_spawn_pos(level_visual)
        game.camera.target = game.player.pos
        game.level.level_visual = level_visual
    } else{
        panic("Map could not load")
    }
}

create_first_test_level :: proc(){
    spawner := create_spawner(5, 0.5, 2)
    spawner.enemy = Enemies.begin_enemy
    add_spawner_to_game(&spawner)
    // append(&game.level.spawner, spawner)
    game.player.pos = {0, 0}
    create_battle_ui()
    level_up_spawner_update()
    if level_visual, ok := m.load_map("assets/test_map.json", game.map_allocator); ok{
        // get_upgrade_target()
        // fill_available_upgrades()
        create_battle_level()
        game.camera.target = game.player.pos
    game.level.level_visual = level_visual
    } else{
        panic("Map could not load")
    }
}

create_test_level :: proc(){
    spawner := create_spawner(10, 0.1, 0)
    spawner.enemy = Enemies.dummy_enemy
    add_spawner_to_game(&spawner)
    // append(&game.level.spawner, spawner)
    spawner = create_spawner(1, 1, 0)
    spawner.enemy = Enemies.begin_charge_enemy
    // append(&game.level.spawner, spawner)
    spawner.enemy = Enemies.viper_enemy
    // append(&game.level.spawner, spawner)
    game.player.pos = {0,0}
    level_visual, ok := m.load_map("assets/test_map.json", game.map_allocator)
    game.level.level_visual = level_visual
    create_battle_level()
    level_up_spawner_update()
    // get_upgrade_target()
    // fill_available_upgrades()
}

create_boss_test_level :: proc(){
    spawner := create_spawner(1, 1, 0)
    spawner.enemy = create_test_boss()
    add_spawner_to_game(&spawner)
    // append(&game.level.spawner, spawner)
    level_visual, ok := m.load_map("assets/test_map.json", game.map_allocator)
    game.level.level_visual = level_visual
    game.player.pos = {0, 0}
    create_battle_level()
    level_up_spawner_update()
    // get_upgrade_target()
    // fill_available_upgrades()
}

create_battle_level :: proc(){
    fill_available_upgrades()
    create_battle_ui()
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
    text := fmt.tprintf("%v", type^)
    return ui.create_button(text, rec, on_click_change_level, type)
}

create_choose_ability_skilltree :: proc(rec : rl.Rectangle, type : ^Unlocked_Data_Type) -> ui.UI_Button{
    text := fmt.tprintf("%v", type^)
    return ui.create_button(text, rec, on_click_skilltree, type)
}

create_choose_bullet_skilltree :: proc(rec : rl.Rectangle, type : ^Skilltree_Bullet_Type) -> ui.UI_Button{
    text := fmt.tprintf("%v", type^)
    return ui.create_button(text, rec, on_click_skilltree, type)
}

refresh_level :: proc(){

    for &n in game.level.npcs{
        n.state = .None
    }

    for &p in game.level.particles{
        p.state = .None
    }

    for &e in game.level.enemies{
        e.state = .None
        for &s in e.statuses{
            s.game_state = .None
        }
    }

    for &s in game.level.spawner{
        s.state = .None
    }

    for &b in game.level.player_bullets{
        b.state = .None
    }

    for &s in game.player.statuses{
        s.game_state = .None
    }


    clear(&game.level.area_effects)
    for &b in game.level.player_bullets{
        delete(b.hitted_enemies)
    }
    clear(&game.level.enemy_bullets)
    clear(&game.level.enemy_fragments)
    clear(&game.level.ui_elements)
    clear(&game.level.available_upgrades)
}

get_next_free_entity :: proc{
    get_next_free_enemy,
    get_next_free_spawner,
    get_next_free_particle,
    get_next_free_npc,
    get_next_free_bullet,
    get_next_free_status,
    get_next_free_loot,
}

get_next_free_enemy :: proc(array : []Enemy) -> i32{
    for i in 0..<len(array){
        if array[i].state == .None do return i32(i)
    }
    return -1
}

get_next_free_spawner :: proc(array : []Spawner) -> i32{
    for i in 0..<len(array){
        if array[i].state == .None do return i32(i)
    }
    return -1
}

get_next_free_particle :: proc(array : []Particle) -> i32{
    for i in 0..<len(array){
        if array[i].state == .None do return i32(i)
    }
    return -1
}

get_next_free_npc :: proc(array : []NPC) -> i32{
    for i in 0..<len(array){
        if array[i].state == .None do return i32(i)
    }
    return -1
}

get_next_free_bullet :: proc(array : []Bullet) -> i32{
    for i in 0..<len(array){
        if array[i].state == .None do return i32(i)
    }
    return -1
}

get_next_free_status :: proc(array : []Status_Effect) -> i32{
    for i in 0..<len(array){
        if array[i].game_state == .None do return i32(i)
    }
    return -1
}

get_next_free_loot :: proc(array : []Loot) -> i32{
    for i in 0..<len(array){
        if array[i].game_state == .None do return i32(i)
    }
    return -1
}

add_entity_to_game :: proc{
    add_spawner_to_game,
    add_enemy_to_game,
    add_particle_to_game,
    add_npc_to_game,
    add_bullet_to_game,
    add_loot_to_game,
}

add_spawner_to_game :: proc(s : ^Spawner){
    free_spawner_idx := get_next_free_entity(game.level.spawner[:])

    if free_spawner_idx == -1 do return

    s.state = .Active
    game.level.spawner[free_spawner_idx] = s^
}

add_enemy_to_game :: proc(e : ^Enemy) -> bool{
    free_enemy_idx := get_next_free_entity(game.level.enemies[:])

    if free_enemy_idx == -1 do return false

    e.state = .Active
    e.id = Enemy_Id
    Enemy_Id += 1
    game.level.enemies[free_enemy_idx] = e^
    return true
}

add_particle_to_game :: proc(p : ^Particle){
    free_particle_idx := get_next_free_entity(game.level.particles[:])

    if free_particle_idx == -1 do return

    p.alive = true
    p.state = .Active
    game.level.particles[free_particle_idx] = p^
}

add_npc_to_game :: proc(n : ^NPC){
    free_npc_idx := get_next_free_entity(game.level.npcs[:])
    
    if free_npc_idx == -1 do return

    n.state = .Active
    game.level.npcs[free_npc_idx] = n^
}

add_bullet_to_game :: proc(b : ^Bullet){
    free_bullet_idx := get_next_free_entity(game.level.player_bullets[:])

    if free_bullet_idx == -1 do return

    b.state = .Active
    game.level.player_bullets[free_bullet_idx] = b^
}

add_loot_to_game :: proc(l : ^Loot){
    free_loot_idx := get_next_free_entity(game.level.loot[:])

    if free_loot_idx == -1 do return

    l.game_state = .Active
    game.level.loot[free_loot_idx] = l^
}