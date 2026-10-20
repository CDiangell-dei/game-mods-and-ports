local dandelionBouquet = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _isOccupied = false

local function _checkIfRowEmpty()
    local x, y = game.control.tiles.getCoordinate(dandelionBouquet.index)
    local width = game.control.tiles.getWidth()
    for i=1, width do
        if i ~= x then
            local index = game.control.tiles.getIndex(i, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil then
                _isOccupied = true
                return
            end
        end
    end
    _isOccupied = false
end

local function _calculatePotentialExhaustion()
    local amount = dandelionBouquet.data.exhaustion + dandelionBouquet.flatModifier
    return math.max(0, amount * dandelionBouquet.percentageModifier)
end

local function _calculateExhaustion()
    if _isOccupied then
        return 0
    end
    return _calculatePotentialExhaustion()
end

function dandelionBouquet.init()
    _checkIfRowEmpty()
end

function dandelionBouquet.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculatePotentialExhaustion()
    end
    return nil
end

function dandelionBouquet.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, dandelionBouquet)
end

function dandelionBouquet.onInventoryChange()
    _checkIfRowEmpty()
end

return dandelionBouquet
