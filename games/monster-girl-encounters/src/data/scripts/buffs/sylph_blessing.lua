local sylphBlessing = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _calculateChance()
    return sylphBlessing.data.amount + (game.control.luck * 0.25)
end

function sylphBlessing.getVar(variableName)
    if variableName == 'amount' then
        return _calculateChance()
    end
end

function sylphBlessing.pump(_)
    local roll = math.random()
    if roll > _calculateChance() * 0.01 then
        return
    end
    game.control.gainGold(1)
    game.audio.playSound('data/sounds/general/purchase.json')
end

return sylphBlessing
