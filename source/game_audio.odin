package game

import "core:math/rand"
import rl "vendor:raylib"

play_sound_varied :: proc(s : rl.Sound, min_pitch : f32 = 0.9, max_pitch : f32 = 1.1){
    pitch := rand.float32_range(min_pitch, max_pitch)
    rl.SetSoundPitch(s, pitch)
    rl.PlaySound(s)
}