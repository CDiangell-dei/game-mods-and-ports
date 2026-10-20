local hungrySlime = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _tryConsume(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return
    end
    if tile._conjured then
        return
    end
    game.control.tiles.destroyTile(index)
    hungrySlime.value = hungrySlime.value + tile.value
    game.control.ui.triggerTile(hungrySlime.index)
    game.audio.playSound('data/sounds/general/consume.json')
end

local function _tryConsumeItem()
    local x, y = game.control.tiles.getCoordinate(hungrySlime.index)
    _tryConsume(x - 1, y)
    _tryConsume(x + 1, y)
end

local function _calculateModifier()
    return hungrySlime.data.modifier + (hungrySlime.value * hungrySlime.data.increase)
end

function hungrySlime.getVar(variableName)
    if variableName == 'modifier' then
        return _calculateModifier()
    elseif variableName == 'increase' then
        return hungrySlime.data.increase
    end
end

function hungrySlime.pump(pumpData)
    local amount = _calculateModifier()
    pumpData.exhaustion = pumpData.exhaustion * amount
    table.insert(pumpData.pumpers, hungrySlime)
end

function hungrySlime.onEnterEncounter(encounterType)
    if encounterType ~= 'battle' and encounterType ~= 'boss' and encounterType ~= 'elite' then
        return
    end
    _tryConsumeItem()
end

return hungrySlime
