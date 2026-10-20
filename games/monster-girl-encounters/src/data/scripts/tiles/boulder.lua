local boulder = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _calculateExhaustion()
    local amount = boulder.data.exhaustion + boulder.flatModifier
    return math.max(0, amount * boulder.percentageModifier)
end

function boulder.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    end
    return nil
end

function boulder.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, boulder)
end

return boulder
