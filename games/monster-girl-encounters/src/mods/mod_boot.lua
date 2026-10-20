-- Chamado por data/scripts/init.lua (_initializeSandbox), logo apos add_encounters.lua.
-- Resolve os mods ativos uma unica vez e os entrega ao jogo.
local manager = require('mods/mod_manager.lua')
manager.boot()
