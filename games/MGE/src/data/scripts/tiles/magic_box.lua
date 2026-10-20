local magicBox = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _increaseExhaustion()
    local requiredExhaustion = game.control.encounter.requiredExhaustion
    local exhaustion = requiredExhaustion * magicBox.data.amount * 0.01
    game.control.encounter.exhaustion = game.control.encounter.exhaustion + exhaustion
end

local function _tryConsume(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return false
    end
    if tile.subtype ~= 'junk' then
        return false
    end
    if tile._conjured then
        return false
    end
    game.control.tiles.destroyTile(index)
    _increaseExhaustion()
    return true
end

local function _tryConsumeItem()
    local x, y = game.control.tiles.getCoordinate(magicBox.index)
    local left = _tryConsume(x - 1, y)
    if left then
        return true
    end
    local right = _tryConsume(x + 1, y)
    if right then
        return true
    end
    local top = _tryConsume(x, y - 1)
    if top then
        return true
    end
    local bot = _tryConsume(x, y + 1)
    return bot
end

function magicBox.getVar(variableName)
    if variableName == 'amount' then
        return magicBox.data.amount
    end
    return nil
end

function magicBox.pump(pumpData)
    local consumed = _tryConsumeItem()
    if consumed then
        table.insert(pumpData.pumpers, magicBox)
        game.audio.playSound('data/sounds/general/consume.json')
    end
end

return magicBox
