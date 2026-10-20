local basket = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _isBottomRow = false

local function _checkIfBottomRow()
    local _, y = game.control.tiles.getCoordinate(basket.index)
    local height = game.control.tiles.getHeight()
    _isBottomRow = y == height
end

local function _calculatePotentialExhaustion()
    local amount = basket.data.exhaustion + basket.flatModifier
    return math.max(0, amount * basket.percentageModifier)
end

local function _calculateExhaustion()
    if not _isBottomRow then
        return 0
    end
    return _calculatePotentialExhaustion()
end

function basket.init()
    _checkIfBottomRow()
end

function basket.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculatePotentialExhaustion()
    end
    return nil
end

function basket.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, basket)
end

function basket.onInventoryChange()
    _checkIfBottomRow()
end

return basket
