local webCoveredRope = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _flatModifier = 0

local function _calculateExhaustion()
    local amount = webCoveredRope.data.exhaustion + webCoveredRope.flatModifier + _flatModifier
    return math.max(0, amount * webCoveredRope.percentageModifier)
end

function webCoveredRope.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return webCoveredRope.data.increase
    end
end

function webCoveredRope.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, webCoveredRope)
end

function webCoveredRope.onRerollShop()
    _flatModifier = _flatModifier + webCoveredRope.data.increase
    game.control.ui.triggerTile(webCoveredRope.index, true)
end

return webCoveredRope
