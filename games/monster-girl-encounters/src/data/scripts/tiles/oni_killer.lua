local oniKiller = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _triggerPump(x, y, pumpData)
    local current = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(current)
    if tile ~= nil and tile.pump ~= nil then
        tile.pump(pumpData)
    end
end

function oniKiller.getVar(variableName)
    --used for variables in tooltips
    if variableName == 'chance' then
        return oniKiller.data.chance
    end
    return nil
end

function oniKiller.pump(pumpData)
    local roll = math.random()
    if roll > oniKiller.data.chance * 0.01 then
        return
    end
    local oniX, oniY = game.control.tiles.getCoordinate(oniKiller.index)
    local width = game.control.tiles.getWidth()
    for x = oniX, width do
        _triggerPump(x, oniY - 1, pumpData)
    end
    for x = 1, oniX - 1 do
        _triggerPump(x, oniY, pumpData)
    end
    table.insert(pumpData.pumpers, oniKiller)
end

return oniKiller
