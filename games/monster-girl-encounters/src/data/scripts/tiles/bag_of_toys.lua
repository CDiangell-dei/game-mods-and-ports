local bagOfToys = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _flatModifier = 0

local function _calculateExhaustion()
    local amount = bagOfToys.data.exhaustion + bagOfToys.flatModifier + _flatModifier
    return math.max(0, amount * bagOfToys.percentageModifier)
end

function bagOfToys.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return bagOfToys.data.increase
    end
    return nil
end

function bagOfToys.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, bagOfToys)
end

function bagOfToys.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        game.control.ui.triggerTile(bagOfToys.index, true)
        _flatModifier = _flatModifier + bagOfToys.data.increase
    end
end

return bagOfToys
