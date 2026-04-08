package map_loader

import "core:mem"
import "core:fmt"


import "core:os"
import "core:encoding/json"
import rl "vendor:raylib"

Tiled_Map :: struct{
    width : int,
    height : int,
    tilewidth : int,
    tileheight : int,
    layers : [dynamic]Tiled_Layer,
    tilesets : [dynamic]Tiled_Tileset,
    texture : rl.Texture2D
}

Tiled_Object :: struct{
    id : f32,
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    name : string,
    type : string,
}

Tiled_Tileset :: struct {
    firstgid : int,
    image : string,
    imagewidth : int,
    imageheight : int,
    margin : int,
    spacing : int,
    tilewidth : int,
    tileheight : int,
}

Tiled_Layer :: struct{
    data : [dynamic]int,
    name : string,
    type : string,
    visible : bool,
    x : int,
    y : int,
    width : int,
    height : int,
    opacity : f32,
    objects : [dynamic]Tiled_Object,
}

load_map :: proc(path : string, allocator : mem.Allocator) -> (Tiled_Map, bool){
    data, ok := os.read_entire_file(path, allocator)
    if ok != os.General_Error.None{
        return {}, false
    }
    level_map : Tiled_Map
    json_err := json.unmarshal(data, &level_map, allocator = allocator)

    if json_err !=  nil{
        fmt.printfln("Error: %v", json_err)
        return {}, false
    }
    level_map.texture = rl.LoadTexture("assets/simple_tilemap_test.png")
    return level_map, true
}

get_player_spawn_pos :: proc(m : Tiled_Map) -> rl.Vector2{
    for layer in m.layers{
        if layer.type == "objectgroup" && layer.name == "SpawnPlayer"{
            object := layer.objects[0]
            pos_x := f32(object.x + object.width/2)
            pos_y := f32(object.y + object.height/2)
            return {pos_x, pos_y}
        }
    }
    return {}
}