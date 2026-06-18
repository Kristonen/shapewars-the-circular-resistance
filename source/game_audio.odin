package game

import "core:math/rand"
import rl "vendor:raylib"

Enemy_Hurt_Sound_Path :: "assets/audio/standard_hurt.wav"
Shoot_Sound_Path :: "assets/audio/standard_shoot.wav"

Audio_Manager :: struct{
    
    player_shoot_sound : rl.Sound,

    enemy_hurt_sound : rl.Sound
    
}

audio_manager : Audio_Manager


play_sound_varied :: proc(s : rl.Sound, min_pitch : f32 = 0.9, max_pitch : f32 = 1.1){
    pitch := rand.float32_range(min_pitch, max_pitch)
    rl.SetSoundPitch(s, pitch)
    rl.PlaySound(s)
}