local sandwich = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _modifiedTiles = {}

local function _calculateExhaustion()
    local amount = sandwich.data.exhaustion + sandwich.flatModifier
    return math.max(0, amount * sandwich.percentageModifier)
end

local function _clearModifiers()
    for _, tile in ipairs(_modifiedTiles) do
        tile.flatModifier = tile.flatModifier - sandwich.data.modifier
    end
    _modifiedTiles = {}
end

local function _adjustModifiers()
    _clearModifiers()
    local _, y = game.control.tiles.getCoordinate(sandwich.index)
    local width = game.control.tiles.getWidth()
    for x=1, width do
        local index = game.control.tiles.getIndex(x, y)
        local tile = game.control.tiles.getTile(index)
        if tile ~= nil and index ~= sandwich.index then
            tile.flatModifier = tile.flatModifier + sandwich.data.modifier
            table.insert(_modifiedTiles, tile)
        end
    end
end

function sandwich.init()
    _adjustModifiers()
end

function sandwich.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'modifier' then
        return sandwich.data.modifier
    end
    return nil
end

function sandwich.onDestroy()
    _clearModifiers()
end

function sandwich.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, sandwich)
end

function sandwich.onInventoryChange()
    _adjustModifiers()
end

return sandwich
