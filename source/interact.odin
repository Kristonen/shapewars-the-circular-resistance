package game

import rl "vendor:raylib"
import cl "collider"

Interactable :: struct{
    text : string,
    collider : cl.Collider_Circle,
}