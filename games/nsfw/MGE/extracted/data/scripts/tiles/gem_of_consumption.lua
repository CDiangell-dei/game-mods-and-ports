local gemOfConsumption = {
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
    if tile.data.rarity < 2 then
        return
    end
    game.control.tiles.destroyTile(index)
    _modifier = _modifier + gemOfConsumption.data.increase
    game.control.ui.triggerTile(gemOfConsumption.index)
    game.audio.playSound('data/sounds/general/consume.json')
end

local function _tryConsumeItem()
    local x, y = game.control.tiles.getCoordinate(gemOfConsumption.index)
    _tryConsume(x, y + 1)
end

function gemOfConsumption.getVar(variableName)
    if variableName == 'modifier' then
        return gemOfConsumption.data.modifier + _modifier
    elseif variableName == 'increase' then
        return gemOfConsumption.data.increase
    end
    return nil
end

function gemOfConsumption.pump(pumpData)
    local multiplier = gemOfConsumption.data.modifier + _modifier
    pumpData.exhaustion = pumpData.exhaustion * multiplier
    table.insert(pumpData.pumpers, gemOfConsumption)
end

function gemOfConsumption.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        _tryConsumeItem()
    end
end

return gemOfConsumption
