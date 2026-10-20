local lustyElixir = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _multiplier = 0

function lustyElixir.getVar(variableName)
    if variableName == 'modifier' then
        return _multiplier + lustyElixir.data.modifier
    elseif variableName == 'increase' then
        return lustyElixir.data.increase
    end
    return nil
end

function lustyElixir.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion * (_multiplier + lustyElixir.data.modifier)
    table.insert(pumpData.pumpers, lustyElixir)
    _multiplier = _multiplier + lustyElixir.data.increase
end

function lustyElixir.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        _multiplier = 0
    end
end

return lustyElixir