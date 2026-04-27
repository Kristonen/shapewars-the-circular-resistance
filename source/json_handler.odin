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

Save_Skilltree_Data :: struct{
    name : string,
    nodes : [dynamic]Save_Skillnode_Data,
}

Save_Skillnode_Data :: struct{
    name : string,
    count : i32,
}

load_tooltips :: proc(){
    refresh_skill_arena()
    data, ok := os.read_entire_file("assets/tooltips.json", game.map_allocator)

    if ok != os.General_Error.None do return
    err := json.unmarshal(data, &game.tooltips, allocator = game.map_allocator)
}

load_skilltree :: proc(){
    refresh_skill_arena()
    data, ok := os.read_entire_file("assets/skilltrees.json", game.skill_allocator)

    if ok != os.General_Error.None do return
    trees : []Save_Skilltree_Data
    err := json.unmarshal(data, &trees, allocator = game.skill_allocator)
    // if err != nil{
    //     panic(fmt.tprintf("%v", err))
    // }

    for tree, tree_idx in trees{
        for node, node_idx in tree.nodes{
            n := &game.skilltrees[tree.name].nodes[node_idx]
            n.count = node.count
        }
    }
    fmt.println(game.skilltrees["NormalBullet"].nodes[0])
}

save_skilltree :: proc(){
    // json_data, err := json.marshal(game.skilltrees, {pretty = true}, context.temp_allocator)
    trees : [dynamic]Save_Skilltree_Data
    defer{
        for tree in trees{
            delete(tree.nodes)
        }
        delete(trees)
    }
    for k, v in game.skilltrees{
        tree : Save_Skilltree_Data
        tree.name = k
        for n in v.nodes{
            node : Save_Skillnode_Data
            node.name = n.name.content
            node.count = n.count
            append(&tree.nodes, node)
        }
        append(&trees, tree)
    }

    json_data, err := json.marshal(trees, {pretty = true}, context.temp_allocator)

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