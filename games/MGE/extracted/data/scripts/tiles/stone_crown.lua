local stoneCrown = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _allCommon()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile.data.rarity > 1 then
                return false
            end
        end
    end
    return true
end

function stoneCrown.getVar(variableName)
    if variableName == 'modifier' then
        return stoneCrown.data.modifier
    end
    return nil
end

function stoneCrown.pump(pumpData)
    if not _allCommon() then
        return
    end
    pumpData.exhaustion = pumpData.exhaustion * stoneCrown.data.modifier
    table.insert(pumpData.pumpers, stoneCrown)
end

return stoneCrown
