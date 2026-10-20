local slimeEssence = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _tryModifyTile(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return
    end
    tile.flatModifier = tile.flatModifier + slimeEssence.data.increase
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

function slimeEssence.getVar(variableName)
    if variableName == 'increase' then
        return slimeEssence.data.increase
    end
    return nil
end

function slimeEssence.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'elite' or encounterType == 'boss' then
        game.control.ui.triggerTile(slimeEssence.index, true)
        _adjustModifier()
    end
end

return slimeEssence
