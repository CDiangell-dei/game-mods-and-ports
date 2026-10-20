local blessedHerbs = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _isOverLimit = false

local function _checkIfOverLimit()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local emptyCount = 0
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile == nil then
                emptyCount = emptyCount + 1
            end
        end
    end
    _isOverLimit = emptyCount < blessedHerbs.data.amount
end

function blessedHerbs.init()
    _checkIfOverLimit()
end

function blessedHerbs.getVar(variableName)
    if variableName == 'amount' then
        return blessedHerbs.data.amount
    elseif variableName == 'modifier' then
        return blessedHerbs.data.modifier
    end
    return nil
end

function blessedHerbs.pump(pumpData)
    if _isOverLimit then
        return
    end
    pumpData.exhaustion = pumpData.exhaustion * blessedHerbs.data.modifier
    table.insert(pumpData.pumpers, blessedHerbs)
end

function blessedHerbs.onInventoryChange()
    _checkIfOverLimit()
end

return blessedHerbs
