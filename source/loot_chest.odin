package game

import "core:math"
import "base:sanitizer"
import "core:math/rand"
import "core:fmt"
import rl "vendor:raylib"

Chest_State :: enum{Idle, Opening, Open}

Chest :: struct{
    pos : rl.Vector2,
    texture : rl.Color,
    interact : Interactable,
    blueprint : Unlocked_Data_Type,
    shard_amount : i32,
    active : bool,
}

create_chest :: proc(pos : rl.Vector2) -> Chest{
    chest : Chest
    switch game.current_level{
        case .HQ:
            chest = create_standard_chest(pos)
            chest.blueprint = .Bomb
        case .Battlefield:
        case .Forest:
        case .Test:
        case .Boss_Test:
    }
    
    return chest
}

create_standard_chest :: proc(pos : rl.Vector2) -> Chest{
    return {
        pos = pos,
        texture = rl.BROWN,
        active = true,
        shard_amount = 20,
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
    bp_chance : f32
    switch game.level.chest.blueprint{
        case .NormalBullet:
        case .PierceBullet:
        case .Dash:
        case .Radial_Liberation:
        case .Bomb:
            bp_chance = Bomb_Chance

    }
    if rand <= bp_chance{
        spawn_bomb_blueprint(game.level.chest.pos)
    }
    spawn_shards_around_chest()
}

spawn_shards_around_chest :: proc(){
    radius : f32 = 40
    duration : f32 = 0.5
    speed : f32 = 500//radius/duration
    for i in 0..<game.level.chest.shard_amount{
        shard : Loot
        angle := (f32(i) / f32(game.level.chest.shard_amount)) * (2.0 * math.PI)
        dir := rl.Vector2{
            math.cos(angle), math.sin(angle)
        }
        shard.speed = speed
        shard.dir = rl.Vector2Normalize(dir)
        shard.state = .Spawning
        shard.max_speed = 500
        shard.acceleration = 2
        shard.on_collect = on_shard_collect
        shard.rec = {
            x = game.level.chest.pos.x,
            y = game.level.chest.pos.y,
            width = 10,
            height = 10,
        }
        // shard.detection.radius = shard.rec.width * 6
        shard.pickup.radius = shard.rec.width/4
        shard.time = duration
        shard.color = rl.SKYBLUE
        shard.on_spawn = on_normal_spawn
        add_entity_to_game(&shard)
    }
}