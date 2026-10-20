local polymorphicGem = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

function polymorphicGem.getVar(variableName)
    if variableName == 'min' then
        return polymorphicGem.data.min
    elseif variableName == 'max' then
        return polymorphicGem.data.max
    end
    return nil
end

function polymorphicGem.pump(pumpData)
    local minimum = polymorphicGem.data.min
    local maximum = polymorphicGem.data.max
    local roll = math.random()
    local amount = ((maximum - minimum) * roll) + minimum
    pumpData.exhaustion = pumpData.exhaustion * amount
    table.insert(pumpData.pumpers, polymorphicGem)
end

return polymorphicGem
