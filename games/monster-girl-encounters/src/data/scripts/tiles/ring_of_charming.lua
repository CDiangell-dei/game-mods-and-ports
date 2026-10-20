local ringOfCharming = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _adjustValues()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local amount = ringOfCharming.data.increase
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil then
                tile.value = tile.value + amount
            end
        end
    end
end

function ringOfCharming.getVar(variableName)
    --used for variables in tooltips
    if variableName == 'increase' then
        return ringOfCharming.data.increase
    end
    return nil
end

function ringOfCharming.onEnterEncounter(encounterType)
    if encounterType ~= 'battle' and encounterType ~= 'boss' and encounterType ~= 'elite' then
        return
    end
    game.control.ui.triggerTile(ringOfCharming.index, true)
    _adjustValues()
end

return ringOfCharming
