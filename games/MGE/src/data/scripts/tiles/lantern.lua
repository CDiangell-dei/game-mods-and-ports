local lantern = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _modifiedTiles = {}

local function _clearModifiers()
    for _, tile in ipairs(_modifiedTiles) do
        tile.flatModifier = tile.flatModifier - lantern.data.modifier
    end
    _modifiedTiles = {}
end

local function _tryModifyTile(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return
    end
    tile.flatModifier = tile.flatModifier + lantern.data.modifier
    table.insert(_modifiedTiles, tile)
end

local function _adjustModifiers()
    _clearModifiers()
    local x, y = game.control.tiles.getCoordinate(lantern.index)
    _tryModifyTile(x - 1, y)
    _tryModifyTile(x + 1, y)
    _tryModifyTile(x, y - 1)
    _tryModifyTile(x, y + 1)
end

function lantern.init()
    _adjustModifiers()
end

function lantern.getVar(variableName)
    if variableName == 'modifier' then
        return lantern.data.modifier
    end
    return nil
end

function lantern.onDestroy()
    _clearModifiers()
end

function lantern.onInventoryChange()
    _adjustModifiers()
end

return lantern