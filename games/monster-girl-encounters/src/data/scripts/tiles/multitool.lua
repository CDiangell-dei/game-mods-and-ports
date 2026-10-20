local multitool = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _modifiedTiles = {}

local function _clearModifiers()
    for _, tile in ipairs(_modifiedTiles) do
        tile.flatModifier = tile.flatModifier - multitool.data.modifier
    end
    _modifiedTiles = {}
end

local function _tryModifyTile(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return
    end
    tile.flatModifier = tile.flatModifier + multitool.data.modifier
    table.insert(_modifiedTiles, tile)
end

local function _adjustModifiers()
    _clearModifiers()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x=1, width do
        for y=1, height do
            _tryModifyTile(x, y)
        end
    end
end

function multitool.init()
    _adjustModifiers()
end

function multitool.getVar(variableName)
    if variableName == 'modifier' then
        return multitool.data.modifier
    end
    return nil
end

function multitool.onDestroy()
    _clearModifiers()
end

function multitool.onInventoryChange()
    _adjustModifiers()
end

return multitool