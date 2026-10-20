local goldenIdol = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _calculateExhaustion()
    local amount = goldenIdol.data.exhaustion + goldenIdol.flatModifier
    local goldModifier = game.control.getGold() * goldenIdol.data.increase
    amount = amount + goldModifier
    return math.max(0, amount * goldenIdol.percentageModifier)
end

function goldenIdol.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return goldenIdol.data.increase
    end
end

function goldenIdol.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, goldenIdol)
end

return goldenIdol
