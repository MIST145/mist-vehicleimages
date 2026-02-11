--[[ ===================================================== ]]--
--[[      MH Vehicle Images V2 - FIXED & OPTIMIZED       ]]--
--[[              by MaDHouSe79 - v2.1.0                  ]]--
--[[ ===================================================== ]]--

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'MaDHouSe79'
description 'MH Vehicle Images V2 - Sistema Dinâmico de Gestão de Imagens de Veículos (Fixed & Optimized)'
version '2.1.0'
repository 'https://github.com/MaDHouSe79/mist-vehicleimages'

dependencies {
    '/server:5848',
    '/onesync',
}

--[[ Shared Scripts ]]--
shared_scripts {
    'config.lua'
}

--[[ Client Scripts ]]--
client_scripts {
    'shared/framework.lua',
    'client/main.lua',
    'client/exports.lua'
}

--[[ Server Scripts ]]--
server_scripts {
    'shared/framework.lua',
    'server/logger.lua',
    'server/database.lua',
    'server/main.lua'
}

--[[ UI (NUI) ]]--
ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'data/vehicles.json'
}

escrow_ignore {
    'config.lua',
    'shared/*.lua',
    'data/*.json'
}