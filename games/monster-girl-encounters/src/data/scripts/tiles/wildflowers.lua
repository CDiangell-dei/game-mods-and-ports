local wildflowers = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _flatModifier = 0

local function _adjustModifier()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local emptyCount = 0
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile == nil then
                emptyCount = emptyCount + 1
            end
        end
    end
    _flatModifier = wildflowers.data.increase * emptyCount
end

local function _calculateExhaustion()
    local amount = wildflowers.data.exhaustion + wildflowers.flatModifier + _flatModifier
    return math.max(0, amount * wildflowers.percentageModifier)
end

function wildflowers.init()
    _adjustModifier()
end

function wildflowers.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return wildflowers.data.increase
    end
    return nil
end

function wildflowers.onInventoryChange()
    _adjustModifier()
end

function wildflowers.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, wildflowers)
end

return wildflowers
