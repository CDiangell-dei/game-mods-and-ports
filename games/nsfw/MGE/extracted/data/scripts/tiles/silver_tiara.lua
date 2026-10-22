local silverTiara = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _modifier = 0

local function _tryConsume(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return
    end
    if tile._conjured then
        return
    end
    game.control.tiles.destroyTile(index)
    _modifier = _modifier + silverTiara.data.increase
    game.control.ui.triggerTile(silverTiara.index)
    game.audio.playSound('data/sounds/general/consume.json')
end

local function _tryConsumeItem()
    local x, y = game.control.tiles.getCoordinate(silverTiara.index)
    _tryConsume(x + 1, y)
end

function silverTiara.getVar(variableName)
    if variableName == 'modifier' then
        return silverTiara.data.modifier + _modifier
    elseif variableName == 'increase' then
        return silverTiara.data.increase
    end
    return nil
end

function silverTiara.pump(pumpData)
    local multiplier = silverTiara.data.modifier + _modifier
    pumpData.exhaustion = pumpData.exhaustion * multiplier
    table.insert(pumpData.pumpers, silverTiara)
end

function silverTiara.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        _tryConsumeItem()
    end
end

return silverTiara
