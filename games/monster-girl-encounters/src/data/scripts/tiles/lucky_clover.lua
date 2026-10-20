local luckyClover = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _current = 0

local function _adjustLuck()
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
    game.control.luck = game.control.luck - _current
    _current = luckyClover.data.amount + (emptyCount * luckyClover.data.increase)
    game.control.luck = game.control.luck + _current
end

function luckyClover.init()
    _adjustLuck()
end

function luckyClover.onDestroy()
    game.control.luck = game.control.luck - _current
    _current = 0
end

function luckyClover.getVar(variableName)
    if variableName == 'amount' then
        return _current
    elseif variableName == 'increase' then
        return luckyClover.data.increase
    end
    return nil
end

function luckyClover.onInventoryChange()
    _adjustLuck()
end

return luckyClover