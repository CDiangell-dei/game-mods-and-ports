local vibratingEgg = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _flatModifier = 0

local function _calculateExhaustion()
    local amount = vibratingEgg.data.exhaustion + vibratingEgg.flatModifier + _flatModifier
    return math.max(0, amount * vibratingEgg.percentageModifier)
end

function vibratingEgg.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return vibratingEgg.data.increase
    end
    return nil
end

function vibratingEgg.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, vibratingEgg)
    _flatModifier = _flatModifier + vibratingEgg.data.increase
end

function vibratingEgg.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        _flatModifier = 0
    end
end

return vibratingEgg
