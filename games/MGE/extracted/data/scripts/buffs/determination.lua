local determination = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _levels = -1
local _isBattle = false

function determination.getVar(variableName)
    if variableName == 'modifier' then
        return determination.data.modifier
    elseif variableName == 'remaining' then
        return determination.data.remaining - _levels
    end
end

function determination.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'elite' or encounterType == 'boss' then
        _isBattle = true
    end
end

function determination.onExitEncounter()
    if not _isBattle then
        return
    end
    _isBattle = false
    _levels = _levels + 1
    if _levels == determination.data.remaining then
        game.control.buffs.remove(determination)
    end
end

function determination.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion * determination.data.modifier
    table.insert(pumpData.pumpers, determination)
end

return determination
