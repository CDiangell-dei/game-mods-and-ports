local wrench = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _tryConsume(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return false
    end
    if tile._conjured then
        return false
    end
    if tile.subtype ~= 'junk' then
        return false
    end
    game.control.tiles.destroyTile(index)
    return true
end

local function _tryCombineJunk()
    local x, y = game.control.tiles.getCoordinate(wrench.index)
    local left = _tryConsume(x - 1, y)
    local right = _tryConsume(x + 1, y)
    local top = _tryConsume(x, y - 1)
    local bot = _tryConsume(x, y + 1)
    local count = 0
    local consumedIndex = 0
    if left then
        count = count + 1
        consumedIndex = game.control.tiles.getIndex(x - 1, y)
    end
    if right then
        count = count + 1
        if consumedIndex == 0 then
            consumedIndex = game.control.tiles.getIndex(x + 1, y)
        end
    end
    if top then
        count = count + 1
        if consumedIndex == 0 then
            consumedIndex = game.control.tiles.getIndex(x, y - 1)
        end
    end
    if bot then
        count = count + 1
        if consumedIndex == 0 then
            consumedIndex = game.control.tiles.getIndex(x, y + 1)
        end
    end
    local roller = dofile('data/scripts/encounters/shop_roller.lua')
    if count > 0 then
        local item
        local rarity = 0
        for _=1, count do
            local temp = roller.getRandomItem()
            if temp.rarity >= rarity then
                item = temp
                rarity = temp.rarity
            end
        end
        game.control.tiles.setTile(consumedIndex, item)
        game.control.ui.triggerTile(wrench.index)
        game.audio.playSound('data/sounds/general/consume.json')
    end
end

function wrench.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        _tryCombineJunk()
    end
end

return wrench
