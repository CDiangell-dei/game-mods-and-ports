local goldenElixir = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _calculateModifier()
    return goldenElixir.data.modifier + (game.control.getGold() * goldenElixir.data.increase)
end

function goldenElixir.getVar(variableName)
    if variableName == 'modifier' then
        return _calculateModifier()
    elseif variableName == 'increase' then
        return goldenElixir.data.increase
    end
end

function goldenElixir.pump(pumpData)
    local amount = _calculateModifier()
    pumpData.exhaustion = pumpData.exhaustion * amount
    table.insert(pumpData.pumpers, goldenElixir)
end

return goldenElixir
