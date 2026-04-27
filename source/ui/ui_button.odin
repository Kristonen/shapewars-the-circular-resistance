package ui

import rl "vendor:raylib"

On_Click :: #type proc(b : UI_Button)

create_button :: proc(text : string, rec : rl.Rectangle, on_click : On_Click, data : $T) -> UI_Button{
    b := UI_Button{
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
        on_click = on_click,
        disabled = false,
    }
    b.storage = 0
    ((^T) (&b.storage))^ = data
    b.data = any{&b.storage, typeid_of(T)}
    return b
}

