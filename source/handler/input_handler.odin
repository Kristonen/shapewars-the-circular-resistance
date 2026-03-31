package handler

import rl "vendor:raylib"

update_pausing :: proc() -> bool{
    return rl.IsKeyPressed(.F1)
}