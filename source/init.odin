package game

import "core:fmt"

init_skilltrees :: proc(){
    for type in Skilltree_Bullet_Type{
        create_skill_tree(type, &game.skilltrees)
    }
    for type in Skilltree_Ability_Type{
        create_skill_tree(type, &game.skilltrees)
    }
}