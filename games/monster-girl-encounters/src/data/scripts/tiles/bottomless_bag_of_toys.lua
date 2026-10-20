local bottomlessBagToys = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _flatModifier = 0

local function _calculateExhaustion()
    local amount = bottomlessBagToys.data.exhaustion + bottomlessBagToys.flatModifier + _flatModifier
    return math.max(0, amount * bottomlessBagToys.percentageModifier)
end

function bottomlessBagToys.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return bottomlessBagToys.data.increase
    end
    return nil
end

function bottomlessBagToys.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, bottomlessBagToys)
end

function bottomlessBagToys.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        game.control.ui.triggerTile(bottomlessBagToys.index, true)
        _flatModifier = _flatModifier + bottomlessBagToys.data.increase
    end
    if encounterType == 'shop' then
        game.control.ui.triggerTile(bottomlessBagToys.index, true)
        _flatModifier = 0
    end
end

return bottomlessBagToys
