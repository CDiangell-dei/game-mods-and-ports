local goldenSlime = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _wasSold = false

local function _getRandomTile()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local count = 1
    for x=1, width do
        for y=1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil then
                count = count + 1
            end
        end
    end
    local roll = math.random(count)
    local lastTile = nil
    for x=1, width do
        for y=1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil then
                roll = roll - 1
                if roll <= 0 then
                    return tile
                end
                lastTile = tile
            end
        end
    end
    return lastTile
end

function goldenSlime.getVar(variableName)
    if variableName == 'chance' then
        return goldenSlime.data.chance
    end
    return nil
end

function goldenSlime.onRemoveTile(removedTile)
    if not _wasSold then
        return
    end
    _wasSold = false
    local roll = math.random()
    if roll >= (goldenSlime.data.chance * 0.01) then
        return
    end
    local tile = _getRandomTile()
    if tile == removedTile or tile == nil then
        tile = goldenSlime
    end
    if game.control.tiles.setFirstOpenSlot(tile.data) then
        game.control.ui.triggerTile(goldenSlime.index, true)
    end
end

function goldenSlime.onSellTile(_)
    _wasSold = true
end

return goldenSlime
