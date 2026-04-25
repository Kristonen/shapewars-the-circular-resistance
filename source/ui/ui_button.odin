package ui

import rl "vendor:raylib"

On_Click :: #type proc(b : UI_Button)

create_button :: proc(text : string, rec : rl.Rectangle, on_click : On_Click, data : any = nil) -> UI_Button{
    return {
        text = {
            content = text,
            font_size = 50,
            text_color = rl.WHITE,
            halign = .Center,
            valign = .Center,
        },
        rec = rec,
        n_color = rl.BROWN,
        color = rl.BROWN,
        f_color = rl.BEIGE,
        p_color = rl.VIOLET,
        state = .None,
        data = data,
        on_click = on_click,
    }
}

