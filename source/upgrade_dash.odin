package game

import rl "vendor:raylib"

create_dash_upgrades :: proc(a : ^[dynamic]Upgrade){
    common := create_upgrade("More Dash", "Decrease the cd of your ability by 5%", 0.95, .Multiplicative, .Common)
    common.target = .Dash
    append(a, common)
}