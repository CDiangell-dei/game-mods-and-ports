local canteen = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _calculateExhaustion()
    local amount = canteen.data.exhaustion + canteen.flatModifier
    return math.max(0, amount * canteen.percentageModifier)
end

function canteen.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    end
    return nil
end

function canteen.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, canteen)
end

return canteen
