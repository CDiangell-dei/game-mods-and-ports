local amuletOfAvarice = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _wasSold = false
local _counter = 0

function amuletOfAvarice.getVar(variableName)
    if variableName == 'remaining' then
        return amuletOfAvarice.data.amount - _counter
    elseif variableName == 'amount' then
        return amuletOfAvarice.data.amount
    end
    return nil
end

function amuletOfAvarice.onRemoveTile(_)
    if _wasSold then
        _wasSold = false
        return
    end
    _counter = _counter + 1
    if _counter < amuletOfAvarice.data.amount then
        game.control.ui.triggerTile(amuletOfAvarice.index, true)
        return
    end
    game.control.ui.triggerTile(amuletOfAvarice.index)
    _counter = 0
    game.control.tiles.addRow()
    game.audio.playSound('data/sounds/general/activation.json')
end

function amuletOfAvarice.onSellTile(_)
    _wasSold = true
end

return amuletOfAvarice
