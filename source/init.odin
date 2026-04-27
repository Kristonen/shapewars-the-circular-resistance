package game

import "core:fmt"
import "ui"

init_skilltrees :: proc(){
    for type in ui.UI_Skill_Tree_Type{
        ui.create_skill_tree(type, &game.skilltrees)
    }
}