fx_version 'cerulean'
game 'gta5'

author 'fluffy'
description 'Duty Zones System'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
}

files {
    'config.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}
