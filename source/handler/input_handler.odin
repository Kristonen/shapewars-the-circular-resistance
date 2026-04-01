package handler

import rl "vendor:raylib"

update_pausing :: proc() -> bool{
    return rl.IsKeyPressed(.F1)
}

update_map_drawing :: proc() -> bool{
    return rl.IsKeyPressed(.Q)
}