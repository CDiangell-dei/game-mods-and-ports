local paintbrush = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _adjustValues(amount)
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile.subtype == 'junk' then
                tile.value = tile.value + amount
            end
        end
    end
end

function paintbrush.init()
    _adjustValues(paintbrush.data.amount)
end

function paintbrush.getVar(variableName)
    --used for variables in tooltips
    if variableName == 'amount' then
        return paintbrush.data.amount
    end
    return nil
end

function paintbrush.onDestroy()
    _adjustValues(-paintbrush.data.amount)
end

function paintbrush.onAddTile(tile)
    if tile ~= nil and tile.subtype == 'junk' then
        tile.value = tile.value + paintbrush.data.amount
    end
end

return paintbrush
