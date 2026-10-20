local gnomeBlessing = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _calculateChance()
    return gnomeBlessing.data.amount + (game.control.luck * 0.2)
end

function gnomeBlessing.getVar(variableName)
    if variableName == 'amount' then
        return _calculateChance()
    end
end

function gnomeBlessing.pump(pumpData)
    local roll = math.random()
    if roll > _calculateChance() * 0.01 then
        return
    end
    game.control.tiles.trigger('pump', pumpData)
end

return gnomeBlessing
