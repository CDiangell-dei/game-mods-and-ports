local queenSlime = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _getFirstItem()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for y=1, height do
        for x=1, width do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile ~= queenSlime then
                return tile
            end
        end
    end
    return nil
end

function queenSlime.getVar(variableName)
    if variableName == 'chance' then
        return queenSlime.data.chance
    end
    return nil
end

function queenSlime.onEnterEncounter(encounterType)
    if encounterType ~= 'battle' and encounterType ~= 'boss' and encounterType ~= 'elite' then
        return
    end
    local tile = _getFirstItem()
    if tile == nil then
        return
    end
    if game.control.tiles.setFirstOpenSlot(tile.data) then
        game.control.ui.triggerTile(queenSlime.index, true)
    end
end

return queenSlime
