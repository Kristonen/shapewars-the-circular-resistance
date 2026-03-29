package game

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

draw_map :: proc(m : Tiled_Map, helper_activated : bool){
    tileset_name := m.tilesets[0].image
    tileset_path := fmt.tprintf("assets/%s", tileset_name)
    // texture := rl.LoadTexture(rl.TextFormat("%s", tileset_path))
    texture := m.texture//rl.LoadTexture("assets/simple_tilemap_test.png")
    tiles_per_row := texture.width / i32(m.tilewidth)

    for layer in m.layers{
        if !layer.visible do continue

        if layer.type == "tilelayer"{
            for pos_y in 0..<m.height{
                for pos_x in 0..<m.width{
                    gid := layer.data[pos_y * m.width + pos_x]
                    if gid == 0 do continue
                    id := i32(gid - 1)
                    
                    source := rl.Rectangle{
                        x = f32((id % tiles_per_row) * i32(m.tilewidth)),
                        y = f32((id / tiles_per_row) * i32(m.tileheight)),
                        width = f32(m.tilewidth),
                        height = f32(m.tileheight),
                    }

                    dest : rl.Vector2
                    dest.x = f32(pos_x * m.tilewidth)
                    dest.y = f32(pos_y * m.tileheight)

                    rl.DrawTextureRec(texture, source, dest, rl.WHITE)
                }
            }
        }

        if layer.type == "objectgroup" && layer.name == "Walls" && helper_activated {
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