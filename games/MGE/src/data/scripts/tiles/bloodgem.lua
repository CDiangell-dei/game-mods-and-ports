local bloodgem = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _flatModifier = 0

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
    _flatModifier = _flatModifier + bloodgem.data.increase
    game.control.ui.triggerTile(bloodgem.index)
    game.audio.playSound('data/sounds/general/consume.json')
end

local function _tryConsumeItem()
    local x, y = game.control.tiles.getCoordinate(bloodgem.index)
    _tryConsume(x, y - 1)
end

local function _calculateExhaustion()
    local amount = bloodgem.data.exhaustion + bloodgem.flatModifier + _flatModifier
    return math.max(0, amount * bloodgem.percentageModifier)
end

function bloodgem.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return bloodgem.data.increase
    end
    return nil
end

function bloodgem.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, bloodgem)
end

function bloodgem.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        _tryConsumeItem()
    end
end

return bloodgem
