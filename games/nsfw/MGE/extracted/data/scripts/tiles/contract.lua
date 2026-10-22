local contract = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _calculateWorth()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local value = 0
    for x=1, width do
        for y=1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil then
                value = value + tile.value
            end
        end
    end
    return value
end

local function _calculateExhaustion()
    local amount = contract.data.exhaustion + contract.flatModifier
    local valueModifier = contract.data.increase * _calculateWorth()
    amount = amount + valueModifier
    return math.max(0, amount * contract.percentageModifier)
end

function contract.getVar(variableName)
    --used for variables in tooltips
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return contract.data.increase
    end
    return nil
end

function contract.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, contract)
end

return contract
