package ui

import rl "vendor:raylib"

create_label :: proc(text : string, rec : rl.Rectangle) -> UI_Label{
    return {
        text = {
            content = text,
            font_size = 30,
            text_color = rl.WHITE,
            halign = .Center,
            valign = .Center,
        },
        rec = rec,
        color = rl.GRAY,
    }
}