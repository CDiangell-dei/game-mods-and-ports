local gardeningGloves = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _data = require('data/scripts/data.lua')

function gardeningGloves.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        if game.control.tiles.isFull() then
            return
        end
        game.control.ui.triggerTile(gardeningGloves.index, true)
        local rock = _data.tiles['rock']
        game.control.tiles.setFirstOpenSlot(rock)
    end
end

return gardeningGloves
