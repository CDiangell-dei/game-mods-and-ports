local doll = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

function doll.onWinBattle()
    local encounterData = game.control.encounterData
    if encounterData == nil or encounterData.key == nil or not string.find(encounterData.key, '^boss_') then
        return
    end
    local data = require('data/scripts/data.lua')
    local index = doll.index
    if index ~= nil then
        game.control.tiles.setTile(index, data.tiles['doll'])
        game.control.shield = (game.control.shield or 0) + 1
        game.audio.playSound('data/sounds/general/heal.json')
        game.control.ui.triggerTile(index)
    end
end

return doll
