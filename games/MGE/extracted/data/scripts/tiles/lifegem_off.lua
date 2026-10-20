local lifegem = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

function lifegem.getVar(variableName)
    if variableName == 'remaining' or variableName == 'progress' then
        return 0
    elseif variableName == 'amount' then
        return lifegem.data.amount
    end
    return nil
end

function lifegem.onWinBattle()
    local encounterData = game.control.encounterData
    if encounterData == nil or encounterData.key == nil or not string.find(encounterData.key, '^boss_') then
        return
    end
    local data = require('data/scripts/data.lua')
    local index = lifegem.index
    if index ~= nil then
        game.control.tiles.setTile(index, data.tiles['lifegem'])
        game.audio.playSound('data/sounds/general/heal.json')
        game.control.ui.triggerTile(index)
    end
end

return lifegem
