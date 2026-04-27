package game

import "core:fmt"

init_skilltrees :: proc(){
    for type in Skilltree_Type{
        create_skill_tree(type, &game.skilltrees)
    }
}