package game

import "core:math/rand"
import "core:fmt"
import rl "vendor:raylib"

Chest_State :: enum{Idle, Opening, Open}

Chest :: struct{
    pos : rl.Vector2,
    texture : rl.Color,
    interact : Interactable,
}

create_chest :: proc(pos : rl.Vector2) -> Chest{
    return {
        pos = pos,
        texture = rl.BROWN,
        interact = {
            text = "E - Open",
            collider = {
                pos = pos,
                radius = 50,
            },
            action = open_chest,
        }
    }
}

open_chest :: proc(){
    fmt.println("Kiste wurde geöffnet!")
    rand := rand.float32()
    if rand <= Bomb_Chance{
        spawn_bomb_blueprint(game.level.chest.pos)
    }
}