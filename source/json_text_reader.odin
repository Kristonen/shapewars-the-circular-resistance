package game

import "core:encoding/json"
import "core:mem"
import "core:os"

get_tooltips :: proc(dic : ^map[string]string, allocator : mem.Allocator){
    data, ok := os.read_entire_file_from_path("assets/tooltips.json", allocator)

    if ok != os.General_Error.None do return

    json.unmarshal(data, dic)
}