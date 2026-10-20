local vampiricNecklace = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _tryModifyTile(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return
    end
    tile.flatModifier = tile.flatModifier + vampiricNecklace.data.increase
end

local function _adjustModifier()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x=1, width do
        for y=1, height do
            _tryModifyTile(x, y)
        end
    end
end

local function _tryConsume(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return false
    end
    if tile._conjured then
        return
    end
    game.control.tiles.destroyTile(index)
    _adjustModifier()
    return true
end

local function _tryConsumeItem()
    local x, y = game.control.tiles.getCoordinate(vampiricNecklace.index)
    local left = _tryConsume(x - 1, y)
    local right = _tryConsume(x + 1, y)
    local top = _tryConsume(x, y - 1)
    local bot = _tryConsume(x, y + 1)
    if left or right or top or bot then
        game.control.ui.triggerTile(vampiricNecklace.index)
        game.audio.playSound('data/sounds/general/consume.json')
    end
end

function vampiricNecklace.getVar(variableName)
    if variableName == 'increase' then
        return vampiricNecklace.data.increase
    end
    return nil
end

function vampiricNecklace.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        _tryConsumeItem()
    end
end

return vampiricNecklace
