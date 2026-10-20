local leftovers = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

function leftovers.getVar(variableName)
    if variableName == 'modifier' then
        return leftovers.data.modifier
    elseif variableName == 'chance' then
        return leftovers.data.chance
    end
    return nil
end

function leftovers.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion * leftovers.data.modifier
    table.insert(pumpData.pumpers, leftovers)
    local roll = math.random()
    if roll > (leftovers.data.chance * 0.01) then
        return
    end
    game.control.tiles.destroyTile(leftovers.index)
    game.audio.playSound('data/sounds/general/tile_super.json')
end

return leftovers
