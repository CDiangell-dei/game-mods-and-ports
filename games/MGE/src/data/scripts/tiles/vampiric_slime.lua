local vampiricSlime = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _increaseExhaustion()
    local requiredExhaustion = game.control.encounter.requiredExhaustion
    local exhaustion = requiredExhaustion * vampiricSlime.data.amount * 0.01
    game.control.encounter.exhaustion = game.control.encounter.exhaustion + exhaustion
end

local function _consumeRandomTile()
    local count = 0
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and not tile._conjured and tile ~= vampiricSlime then
                count = count + 1
            end
        end
    end
    if count == 0 then
        return false
    end
    local roll = math.random(count)
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and not tile._conjured and tile ~= vampiricSlime then
                roll = roll - 1
                if roll <= 0 then
                    game.control.tiles.destroyTile(index)
                    _increaseExhaustion()
                    return true
                end
            end
        end
    end
    return false
end

local function _tryConsumeItem()
    if game.control.encounter.exhaustion >= game.control.encounter.requiredExhaustion then
        return false
    end
    return _consumeRandomTile()
end

function vampiricSlime.getVar(variableName)
    if variableName == 'amount' then
        return vampiricSlime.data.amount
    end
    return nil
end

function vampiricSlime.pump(pumpData)
    local consumed = _tryConsumeItem()
    if consumed then
        table.insert(pumpData.pumpers, vampiricSlime)
        game.audio.playSound('data/sounds/general/consume.json')
    end
end

return vampiricSlime
