local jesterHat = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _count = 0
local _uniques = {}

local function _calculateModifier()
    return jesterHat.data.modifier + (_count * jesterHat.data.increase)
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
    elseif variableName == 'increase' then
        return jesterHat.data.increase
    end
end

function jesterHat.pump(pumpData)
    local amount = _calculateModifier()
    pumpData.exhaustion = pumpData.exhaustion * amount
    table.insert(pumpData.pumpers, jesterHat)
end

return jesterHat
