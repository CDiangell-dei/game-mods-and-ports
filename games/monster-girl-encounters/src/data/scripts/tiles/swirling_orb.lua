local swirlingOrb = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

function swirlingOrb.getVar(variableName)
    if variableName == 'min' then
        return swirlingOrb.data.min
    elseif variableName == 'max' then
        return swirlingOrb.data.max
    else
        return nil
    end
end

function swirlingOrb.onEnterEncounter(encounterType)
    if encounterType ~= 'battle' and encounterType ~= 'boss' and encounterType ~= 'elite' then
        return
    end
    game.control.ui.triggerTile(swirlingOrb.index, true)
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x=1, width do
        for y=1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            local amount = (math.random() * (swirlingOrb.data.max - swirlingOrb.data.min)) + swirlingOrb.data.min
            if tile ~= nil then
                tile.percentageModifier = tile.percentageModifier * amount
            end
        end
    end
end

return swirlingOrb
