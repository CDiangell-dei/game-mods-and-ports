-- Luvas de Jardinagem (Balance): ao entrar em batalha adiciona um item:
--   95% de chance: uma Pedra (efeito original)    5% de chance: um item COMUM aleatorio.
local gardeningGloves = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _data = require('data/scripts/data.lua')

local function _isLocked(item)
    if item.requiredTriggers == nil then
        return false
    end
    for _, v in ipairs(item.requiredTriggers) do
        if game.data.getProgress(v.id) ~= v.value then
            return true
        end
    end
    return false
end

local function _countInInventory(key)
    local count = 0
    for i = 1, game.control.tiles.getCount() do
        local tile = game.control.tiles.getTile(i)
        if tile ~= nil and tile.data.key == key then
            count = count + 1
        end
    end
    return count
end

-- mesmas regras de exclusao do sorteador do jogo: sem lixo, respeita limite e travas
local function _commonPool()
    local keys = {}
    for key, item in pairs(_data.tiles) do
        if item.rarity == 1 and item.subtype ~= 'junk' and not _isLocked(item) then
            if item.limit < 1 or _countInInventory(key) < item.limit then
                table.insert(keys, key)
            end
        end
    end
    table.sort(keys)
    return keys
end

function gardeningGloves.getVar(variableName)
    if variableName == 'chance' then
        return gardeningGloves.data.chance
    end
    return nil
end

function gardeningGloves.onEnterEncounter(encounterType)
    if encounterType ~= 'battle' and encounterType ~= 'boss' and encounterType ~= 'elite' then
        return
    end
    if game.control.tiles.isFull() then
        return
    end
    local reward = _data.tiles['rock']
    if math.random() * 100 < gardeningGloves.data.chance then
        local pool = _commonPool()
        if #pool > 0 then
            reward = _data.tiles[pool[math.random(#pool)]]
        end
    end
    game.control.ui.triggerTile(gardeningGloves.index, true)
    game.control.tiles.setFirstOpenSlot(reward)
end

return gardeningGloves
