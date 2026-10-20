local pottedClover = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _calculateGold()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local emptyCount = 0
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile == nil then
                emptyCount = emptyCount + 1
            end
        end
    end
    return pottedClover.data.amount * emptyCount
end

function pottedClover.getVar(variableName)
    if variableName == 'amount' then
        return pottedClover.data.amount
    end
end

function pottedClover.onWinBattle()
    local gold = _calculateGold()
    game.control.gainGold(gold)
    game.audio.playSound('data/sounds/general/purchase.json')
end

return pottedClover