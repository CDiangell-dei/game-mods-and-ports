local map = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _modifiedTiles = {}

local function _clearModifiers()
    for _, tile in ipairs(_modifiedTiles) do
        tile.flatModifier = tile.flatModifier - map.data.modifier
    end
    _modifiedTiles = {}
end

local function _tryModifyTile(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return
    end
    tile.flatModifier = tile.flatModifier + map.data.modifier
    table.insert(_modifiedTiles, tile)
end

local function _adjustModifiers()
    _clearModifiers()
    local _, y = game.control.tiles.getCoordinate(map.index)
    local width = game.control.tiles.getWidth()
    for x=1, width do
        _tryModifyTile(x, y)
    end
end

function map.init()
    _adjustModifiers()
end

function map.getVar(variableName)
    if variableName == 'modifier' then
        return map.data.modifier
    end
    return nil
end

function map.onDestroy()
    _clearModifiers()
end

function map.onInventoryChange()
    _adjustModifiers()
end

return map