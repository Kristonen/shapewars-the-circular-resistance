package game

Spawner :: struct{
    enemy : Enemy,
    count : i32,
    max_count : i32,
    increase : i32,
    spawn_time : f32,
    spawn_timer : f32,
    level_cond : i32,
    is_active : bool,
}

create_spawner :: proc(max_count : i32, spawn_time : f32, increase : i32, cond : i32 = 1) -> Spawner{
    return {
        max_count = max_count,
        spawn_time = spawn_time,
        increase = increase,
        level_cond = cond,
    }
}

level_up_spawner_update :: proc(){
    for &s in game.level.spawner{
        if s.level_cond == game.player.loot_bag.level{
            s.is_active = true
            continue
        }

        if s.level_cond < game.player.loot_bag.level{
            s.max_count += s.increase
        }
    }
}