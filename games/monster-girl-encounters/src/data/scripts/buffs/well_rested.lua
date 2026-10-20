local wellRested = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _levels = -1
local _isBattle = false

function wellRested.getVar(variableName)
    if variableName == 'modifier' then
        return wellRested.data.modifier
    elseif variableName == 'remaining' then
        return wellRested.data.remaining - _levels
    end
end

function wellRested.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'elite' or encounterType == 'boss' then
        _isBattle = true
    end
end

function wellRested.onExitEncounter()
    if not _isBattle then
        return
    end
    _isBattle = false
    _levels = _levels + 1
    if _levels == wellRested.data.remaining then
        game.control.buffs.remove(wellRested)
    end
end

function wellRested.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion * wellRested.data.modifier
    table.insert(pumpData.pumpers, wellRested)
end

return wellRested
