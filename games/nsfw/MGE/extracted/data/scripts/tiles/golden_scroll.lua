local goldenScroll = {
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

local function _calculateModifier()
    return goldenScroll.data.modifier + (_calculateWorth() * goldenScroll.data.increase)
end

function goldenScroll.getVar(variableName)
    --used for variables in tooltips
    if variableName == 'modifier' then
        return _calculateModifier()
    elseif variableName == 'increase' then
        return goldenScroll.data.increase
    end
    return nil
end

function goldenScroll.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion * _calculateModifier()
    table.insert(pumpData.pumpers, goldenScroll)
end

return goldenScroll
