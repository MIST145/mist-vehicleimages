fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Mist_Goat'
description 'MIST Vehicle Images V2 - Sistema Dinâmico de Gestão de Imagens de Veículos (Fixed & Optimized)'
version '2.1.0'
repository 'https://github.com/MIST145/mist-vehicleimages'

shared_scripts {
    'config.lua'
}

client_scripts {
    'shared/framework.lua',
    'client/main.lua',
    'client/exports.lua'
}

server_scripts {
    'shared/framework.lua',
    'server/logger.lua',
    'server/database.lua',
    'server/main.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'data/vehicles.json'
}
