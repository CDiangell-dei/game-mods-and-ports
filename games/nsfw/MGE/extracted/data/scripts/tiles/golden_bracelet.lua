local goldenBracelet = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _wasSold = false

function goldenBracelet.getVar(variableName)
    if variableName == 'amount' then
        return goldenBracelet.data.amount
    end
    return nil
end

function goldenBracelet.onRemoveTile(_)
    if _wasSold then
        _wasSold = false
        return
    end
    game.control.gainGold(goldenBracelet.data.amount)
    game.audio.playSound('data/sounds/general/purchase.json')
    game.control.ui.triggerTile(goldenBracelet.index)
end

function goldenBracelet.onSellTile(_)
    _wasSold = true
end

return goldenBracelet
