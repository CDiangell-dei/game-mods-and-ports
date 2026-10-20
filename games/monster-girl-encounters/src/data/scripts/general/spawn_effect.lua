
local function _init(spawnData)
    local effectSpawner = require('data/scripts/ui/effect_spawner.lua')
    local key = spawnData.key
    local range = spawnData.range
    local color = spawnData.color
    effectSpawner.spawn(key, range, color)
end

return _init