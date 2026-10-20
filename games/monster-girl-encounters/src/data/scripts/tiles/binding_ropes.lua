local bindingRopes = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _flatModifier = 0

local function _calculateExhaustion()
    local amount = bindingRopes.data.exhaustion + bindingRopes.flatModifier + _flatModifier
    return math.max(0, amount * bindingRopes.percentageModifier)
end

function bindingRopes.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return bindingRopes.data.increase
    end
    return nil
end

function bindingRopes.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, bindingRopes)
end

function bindingRopes.onEnterEncounter(encounterType)
    if encounterType == 'elite' or encounterType == 'boss' then
        _flatModifier = _flatModifier + bindingRopes.data.increase
    end
end

return bindingRopes
