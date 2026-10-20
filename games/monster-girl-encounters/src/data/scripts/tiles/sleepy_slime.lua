local sleepySlime = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

function sleepySlime.getVar(variableName)
    --used for variables in tooltips
    if variableName == 'amount' then
        return sleepySlime.data.amount
    end
    return nil
end

function sleepySlime.pump(pumpData)
    local roll = math.random()
    table.insert(pumpData.pumpers, sleepySlime)
    if roll >= (sleepySlime.data.amount * 0.01) then
        return
    end
    local index = sleepySlime.index
    for i=1, index - 1 do
        local tile = game.control.tiles.getTile(i)
        if tile ~= nil and tile.pump ~= nil then
            tile.pump(pumpData)
        end
    end
end

return sleepySlime
