local toolbox = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _flatModifier = 0

local function _adjustModifier()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local junkCount = 0
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile.subtype == 'junk' then
                junkCount = junkCount + 1
            end
        end
    end
    _flatModifier = toolbox.data.increase * junkCount
end

local function _calculateExhaustion()
    local amount = toolbox.data.exhaustion + toolbox.flatModifier + _flatModifier
    return math.max(0, amount * toolbox.percentageModifier)
end

function toolbox.init()
    _adjustModifier()
end

function toolbox.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return toolbox.data.increase
    end
    return nil
end

function toolbox.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, toolbox)
end

function toolbox.onInventoryChange()
    _adjustModifier()
end

return toolbox
