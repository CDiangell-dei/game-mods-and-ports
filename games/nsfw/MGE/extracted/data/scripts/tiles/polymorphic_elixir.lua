local polymorphicElixir = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _calculateMinExhaustion()
    local amount = polymorphicElixir.data.min - polymorphicElixir.flatModifier
    return math.max(0, amount) -- cap to 0 for range from 0 - max
end

local function _calculateMaxExhaustion()
    local amount = polymorphicElixir.data.max + polymorphicElixir.flatModifier
    return math.max(0, amount * polymorphicElixir.percentageModifier)
end

function polymorphicElixir.getVar(variableName)
    if variableName == 'min' then
        return _calculateMinExhaustion()
    elseif variableName == 'max' then
        return _calculateMaxExhaustion()
    end
    return nil
end

function polymorphicElixir.pump(pumpData)
    local minimum = -_calculateMinExhaustion()
    local maximum = _calculateMaxExhaustion()
    local roll = math.random()
    local amount = ((maximum - minimum) * roll) + minimum
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, polymorphicElixir)
end

return polymorphicElixir
