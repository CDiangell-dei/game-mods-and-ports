-- Ervas Benzidas (Balance): multiplicador ADITIVO. Base 1x, +1.5x para cada grupo completo de
-- 5 espacos vazios (5 vazios = 2.5x, 10 = 4x, 15 = 5.5x). Sem grupo completo, nao faz nada.
local blessedHerbs = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _groups = 0

local function _updateGroups()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local emptyCount = 0
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            if game.control.tiles.getTile(index) == nil then
                emptyCount = emptyCount + 1
            end
        end
    end
    _groups = math.floor(emptyCount / blessedHerbs.data.amount)
end

local function _calculateModifier()
    return 1 + (_groups * blessedHerbs.data.modifier)
end

function blessedHerbs.init()
    _updateGroups()
end

function blessedHerbs.onInventoryChange()
    _updateGroups()
end

function blessedHerbs.getVar(variableName)
    if variableName == 'amount' then
        return blessedHerbs.data.amount
    elseif variableName == 'modifier' then
        return blessedHerbs.data.modifier
    end
    return nil
end

function blessedHerbs.pump(pumpData)
    if _groups < 1 then
        return
    end
    pumpData.exhaustion = pumpData.exhaustion * _calculateModifier()
    table.insert(pumpData.pumpers, blessedHerbs)
end

return blessedHerbs
