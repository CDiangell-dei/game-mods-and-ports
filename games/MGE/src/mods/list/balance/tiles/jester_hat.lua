-- Chapeu de Bobo (Balance): +6% DO VALOR DO MULTIPLICADOR por item diferente no inventario.
-- Ou seja, composto: x1.0 * 1.06 ^ (itens diferentes). O original somava +0.06x fixo por item.
local jesterHat = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _count = 0
local _uniques = {}

local function _calculateModifier()
    local growth = 1 + (jesterHat.data.increasePercent / 100)
    return jesterHat.data.modifier * (growth ^ _count)
end

local function _countUniques()
    local count = 0
    for _, _ in pairs(_uniques) do
        count = count + 1
    end
    _count = count
end

local function _refreshUniques()
    _uniques = {}
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil then
                _uniques[tile.data] = 1
            end
        end
    end
    _countUniques()
end

function jesterHat.init()
    _refreshUniques()
end

function jesterHat.onInventoryChange()
    _refreshUniques()
end

function jesterHat.getVar(variableName)
    if variableName == 'modifier' then
        return _calculateModifier()
    elseif variableName == 'increasePercent' then
        return jesterHat.data.increasePercent
    end
    return nil
end

function jesterHat.pump(pumpData)
    local amount = _calculateModifier()
    pumpData.exhaustion = pumpData.exhaustion * amount
    table.insert(pumpData.pumpers, jesterHat)
end

return jesterHat
