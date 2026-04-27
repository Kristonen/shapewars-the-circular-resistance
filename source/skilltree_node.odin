package game

apply_dmg_node :: proc(n : ^UI_Skill_Node){
    n.count += 1
    stat := &game.player.weapon.bullet.damage
    stat^ += 10
}