fx_version 'cerulean'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
game 'gta5'

name 'mad-duck'
author 'MadCap'
version '1.1.0'
description 'Quack quack quack'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

files {
    'data/madduck_sounds.dat54.rel',
    'audiodirectory/duck_sounds.awc'
}

data_file 'AUDIO_WAVEPACK'  'audiodirectory'
data_file 'AUDIO_SOUNDDATA' 'data/madduck_sounds.dat'
