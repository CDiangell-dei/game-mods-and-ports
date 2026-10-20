local lifegem = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _wasSold = false
local _counter = 0

function lifegem.getVar(variableName)
    if variableName == 'remaining' then
        return lifegem.data.amount - _counter
    elseif variableName == 'amount' then
        return lifegem.data.amount
    end
    return nil
end

function lifegem.onRemoveTile(_)
    if _wasSold then
        _wasSold = false
        return
    end
    _counter = _counter + 1
    if _counter < lifegem.data.amount then
        return
    end
    _counter = 0
    game.control.gainLife()
    game.audio.playSound('data/sounds/general/heal.json')
    game.control.ui.triggerTile(lifegem.index)
end

function lifegem.onSellTile(_)
    _wasSold = true
end

return lifegem
