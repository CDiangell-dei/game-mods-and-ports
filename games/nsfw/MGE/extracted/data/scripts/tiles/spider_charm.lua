local spiderCharm = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

function spiderCharm.getVar(variableName)
    if variableName == 'amount' then
        return spiderCharm.data.amount
    end
    return nil
end

function spiderCharm.onRerollShop()
    game.control.luck = game.control.luck + spiderCharm.data.amount
    game.control.ui.triggerTile(spiderCharm.index, true)
end

return spiderCharm
