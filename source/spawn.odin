package game

import rl "vendor:raylib"

Spawner :: struct{
    enemy : Dummy_Enemy,
    count : i32,
    max_count : i32,
    increase : i32,
    spawn_time : f32,
    spawn_timer : f32,
    level_cond : i32,
}

create_spawner :: proc(max_count : i32, spawn_time : f32, increase : i32, cond : i32 = 1) -> Spawner{
    return {
        enemy = create_enemy({}),
        max_count = max_count,
        spawn_time = spawn_time,
        increase = increase,
        level_cond = cond,
    }
}

level_up_spawner_update :: proc(g : ^Game_State){
    for &s in g.spawner{
        if s.level_cond >= g.player.loot_bag.level do continue
        s.max_count += s.increase
    }
}