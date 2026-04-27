package game

import "core:mem/virtual"
import "core:bytes"
import "vendor:zlib"
import "core:fmt"
import "core:encoding/json"
import "core:mem"
import "core:os"
import rl "vendor:raylib"

Save_Player_Data :: struct{
    base_dmg : f32,
    base_hp : f32,
    target_ability : Upgrade_Target,
}

load_tooltips :: proc() -> (map[string]string, bool){
    refresh_skill_arena()
    data, ok := os.read_entire_file("assets/tooltips.json", game.map_allocator)

    if ok != os.General_Error.None do return {}, false
    tooltips : map[string]string
    err := json.unmarshal(data, &tooltips, allocator = game.map_allocator)
    defer delete(tooltips)
    return tooltips, true
}

load_skilltree :: proc(){
    refresh_skill_arena()
    data, ok := os.read_entire_file("assets/skilltrees.json", game.skill_allocator)

    if ok != os.General_Error.None do return
    err := json.unmarshal(data, &game.skilltrees, allocator = game.skill_allocator)
    if err != nil{
        panic(fmt.tprintf("%v", err))
    }
}

save_skilltree :: proc(){
    json_data, err := json.marshal(game.skilltrees, {pretty = true}, context.temp_allocator)
    
    if err != json.Marshal_Data_Error.None{
        fmt.println("Could not parse into json format.")
        fmt.println(err)
        return
    }

    succes := os.write_entire_file("assets/skilltrees.json", json_data)
    if succes != os.General_Error.None{
        fmt.println("Could not save the data.")
    }
}

load_player :: proc(){
    refresh_skill_arena()
    data, ok := os.read_entire_file("assets/player.json", game.skill_allocator)

    if ok != os.General_Error.None do return
    player_data : Save_Player_Data
    err := json.unmarshal(data, &player_data, allocator = game.skill_allocator)
    if err != nil{
        panic(fmt.tprintf("%v", err))
    }
    game.player.weapon.bullet.damage = player_data.base_dmg
    game.player.health.current = player_data.base_hp
    game.player.target_ability = player_data.target_ability
}

save_player :: proc(){
    player_data := Save_Player_Data{
        base_dmg = game.player.weapon.bullet.damage,
        base_hp = game.player.health.current,
        target_ability = game.player.target_ability
    }
    json_data, err := json.marshal(player_data, {pretty = true}, context.temp_allocator)
    
    if err != json.Marshal_Data_Error.None{
        fmt.println("Could not parse into json format.")
        fmt.println(err)
        return
    }

    succes := os.write_entire_file("assets/player.json", json_data)
    if succes != os.General_Error.None{
        fmt.println("Could not save the data.")
    }
}

refresh_skill_arena :: proc(){
    virtual.arena_destroy(&game.skill_arena)
    err := virtual.arena_init_growing(&game.skill_arena)
    game.skill_allocator = virtual.arena_allocator(&game.skill_arena)
}