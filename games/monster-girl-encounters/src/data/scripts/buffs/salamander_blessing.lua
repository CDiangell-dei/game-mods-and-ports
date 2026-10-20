local salamanderBlessing = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _levels = 0
local _isBattle = false

function salamanderBlessing.getVar(variableName)
    if variableName == 'remaining' then
        return math.max(_levels, 0)
    elseif variableName == 'amount' then
        return salamanderBlessing.data.amount
    elseif variableName == 'modifier' then
        return salamanderBlessing.data.modifier
    end
end

function salamanderBlessing.pump(pumpData)
    if _levels <= 0 then
        return
    end
    pumpData.exhaustion = pumpData.exhaustion * salamanderBlessing.data.modifier
    table.insert(pumpData.pumpers, salamanderBlessing)
end

function salamanderBlessing.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'elite' or encounterType == 'boss' then
        _isBattle = true
    end
end

function salamanderBlessing.onLoseBattle()
    _levels = salamanderBlessing.data.amount + 1
end

function salamanderBlessing.onExitEncounter()
    if not _isBattle then
        return
    end
    _isBattle = false
    _levels = _levels - 1
end

return salamanderBlessing
