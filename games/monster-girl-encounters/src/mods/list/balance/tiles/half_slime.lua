-- Meia Gosma (Balance): so repete o "Ao bombear" do item da esquerda com 50% de chance.
local halfSlime = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

function halfSlime.getVar(variableName)
    if variableName == 'chance' then
        return halfSlime.data.chance
    end
    return nil
end

function halfSlime.pump(pumpData)
    local index = halfSlime.index
    local x, y = game.control.tiles.getCoordinate(index)
    if x <= 1 then
        return
    end
    local tileIndex = game.control.tiles.getIndex(x - 1, y)
    local tile = game.control.tiles.getTile(tileIndex)
    if tile == nil then
        return
    end
    if tile.pump == nil then
        return
    end
    if math.random() * 100 >= halfSlime.data.chance then
        return
    end
    tile.pump(pumpData)
    table.insert(pumpData.pumpers, halfSlime)
end

return halfSlime
