local chaoticOrb = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local function _getRandomTile()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local count = 1
    for x=1, width do
        for y=1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and index ~= chaoticOrb.index and not tile._conjured then
                count = count + 1
            end
        end
    end
    local roll = math.random(count)
    local lastTile = nil
    for x=1, width do
        for y=1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and index ~= chaoticOrb.index and not tile._conjured then
                roll = roll - 1
                if roll <= 0 then
                    return tile
                end
                lastTile = tile
            end
        end
    end
    return lastTile
end

local function _increaseMultipliers()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x=1, width do
        for y=1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil then
                tile.percentageModifier = tile.percentageModifier * chaoticOrb.data.modifier
            end
        end
    end
end

function chaoticOrb.getVar(variableName)
    if variableName == 'modifier' then
        return chaoticOrb.data.modifier
    end
    return nil
end

function chaoticOrb.onEnterEncounter(encounterType)
    if encounterType ~= 'battle' and encounterType ~= 'boss' and encounterType ~= 'elite' then
        return
    end
    local tile = _getRandomTile()
    if tile == nil then
        return
    end
    game.control.ui.triggerTile(chaoticOrb.index)
    game.control.tiles.destroyTile(tile.index)
    game.audio.playSound('data/sounds/general/consume.json')
    _increaseMultipliers()
end

return chaoticOrb
