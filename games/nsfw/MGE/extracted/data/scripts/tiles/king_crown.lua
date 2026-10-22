local kingCrown = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

function kingCrown.init()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile ~= kingCrown then
                tile.subtype = 'junk'
            end
        end
    end
end

function kingCrown.onDestroy()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile ~= kingCrown then
                tile.subtype = tile.data.subtype
            end
        end
    end
end

function kingCrown.onAddTile(tile)
    tile.subtype = 'junk'
end

return kingCrown
