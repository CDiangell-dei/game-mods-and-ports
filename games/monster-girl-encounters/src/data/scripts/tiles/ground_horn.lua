local groundHorn = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _increase = 0
local _modifiedTiles = {}

local function _clearModifiers()
    for _, tileModifier in ipairs(_modifiedTiles) do
        tileModifier.tile.percentageModifier =
            tileModifier.tile.percentageModifier / tileModifier.amount
    end
    _modifiedTiles = {}
end

local function _calculateModifier()
    return groundHorn.data.modifier + _increase
end

local function _tryModifyTile(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return
    end
    local amount = _calculateModifier()
    tile.percentageModifier = tile.percentageModifier * amount
    local modifiedTile = {
        tile = tile,
        amount = amount,
    }
    table.insert(_modifiedTiles, modifiedTile)
end

local function _adjustModifier()
    _clearModifiers()
    local x, y = game.control.tiles.getCoordinate(groundHorn.index)
    local width = game.control.tiles.getWidth()
    for checkX = x + 1, width do
        local lowY = y - (checkX - x)
        local highY = y + (checkX - x)
        _tryModifyTile(checkX, lowY)
        _tryModifyTile(checkX, highY)
    end
    for checkX = 1, x - 1 do
        local lowY = y - (x - checkX)
        local highY = y + (x - checkX)
        _tryModifyTile(checkX, lowY)
        _tryModifyTile(checkX, highY)
    end
end

function groundHorn.init()
    _adjustModifier()
end

function groundHorn.getVar(variableName)
    if variableName == 'modifier' then
        return _calculateModifier()
    elseif variableName == 'increase' then
        return groundHorn.data.increase
    end
    return nil
end

function groundHorn.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'elite' or encounterType == 'boss' then
        game.control.ui.triggerTile(groundHorn.index, true)
        _increase = _increase + groundHorn.data.increase
    end
end

function groundHorn.onInventoryChange()
    _adjustModifier()
end

return groundHorn
