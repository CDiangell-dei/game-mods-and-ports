local compass = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _modifiedTiles = {}

local function _clearModifiers()
    for _, tile in ipairs(_modifiedTiles) do
        tile.flatModifier = tile.flatModifier - compass.data.modifier
    end
    _modifiedTiles = {}
end

local function _tryModifyTile(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return
    end
    tile.flatModifier = tile.flatModifier + compass.data.modifier
    table.insert(_modifiedTiles, tile)
end

local function _adjustModifiers()
    _clearModifiers()
    local x, _ = game.control.tiles.getCoordinate(compass.index)
    local height = game.control.tiles.getHeight()
    for y=1, height do
        _tryModifyTile(x, y)
    end
end

function compass.init()
    _adjustModifiers()
end

function compass.getVar(variableName)
    if variableName == 'modifier' then
        return compass.data.modifier
    end
    return nil
end

function compass.onDestroy()
    _clearModifiers()
end

function compass.onInventoryChange()
    _adjustModifiers()
end

return compass