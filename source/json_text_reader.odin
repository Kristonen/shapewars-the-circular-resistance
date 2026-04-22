package game

import "core:encoding/json"
import "core:mem"
import "core:os"

get_tooltips :: proc(allocator : mem.Allocator) -> (map[string]string, bool){
    data, ok := os.read_entire_file("assets/tooltips.json", allocator)

    if ok != os.General_Error.None do return {}, false
    tooltips : map[string]string
    err := json.unmarshal(data, &tooltips, allocator = allocator)
    defer delete(tooltips)
    return tooltips, true
}