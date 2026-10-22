local sparklingCrown = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _getRareOrBetterCount()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local count = 0
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile.data.rarity > 2 then
                count = count + 1
            end
        end
    end
    return count
end

local function _calculateModifier()
    local count = _getRareOrBetterCount()
    return sparklingCrown.data.modifier + (count * sparklingCrown.data.increase)
end

function sparklingCrown.getVar(variableName)
    if variableName == 'modifier' then
        return _calculateModifier()
    elseif variableName == 'increase' then
        return sparklingCrown.data.increase
    end
    return nil
end

function sparklingCrown.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion * _calculateModifier()
    table.insert(pumpData.pumpers, sparklingCrown)
end

return sparklingCrown
