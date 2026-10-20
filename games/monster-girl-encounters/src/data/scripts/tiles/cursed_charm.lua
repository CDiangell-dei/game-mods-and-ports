local cursedCharm = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _calculateExhaustion()
    local amount = cursedCharm.data.amount + cursedCharm.flatModifier
    return math.max(0, amount * cursedCharm.percentageModifier)
end

function cursedCharm.init()
    game.control.luck = game.control.luck - cursedCharm.data.decrease
end

function cursedCharm.onDestroy()
    game.control.luck = game.control.luck + cursedCharm.data.decrease
end

function cursedCharm.getVar(variableName)
    if variableName == 'amount' then
        return _calculateExhaustion()
    elseif variableName == 'decrease' then
        return cursedCharm.data.decrease
    end
    return nil
end

function cursedCharm.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, cursedCharm)
end

return cursedCharm
