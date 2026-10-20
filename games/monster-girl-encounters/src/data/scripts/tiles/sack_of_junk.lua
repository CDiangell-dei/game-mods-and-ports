local sackOfJunk = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _data = require('data/scripts/data.lua')
local _wasSold = false
local _junk = {
    rock = 0.9,
    boulder = 0.35,
    broken_doll = 0.5,
    bone = 0.9,
    gravel = 0.9,
}

local function _tryReplace()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local junk = {}
    for x=1, width do
        for y=1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile.subtype == 'junk' then
                table.insert(junk, tile)
            end
        end
    end
    if #junk < 1 then
        return
    end
    local i = math.random(#junk)
    local replaced = junk[i]
    if replaced == nil then
        return
    end
    local roller = dofile('data/scripts/encounters/shop_roller.lua')
    local randomItem = roller.getRandomItem()
    game.control.tiles.setTile(replaced.index, randomItem)
    game.audio.playSound('data/sounds/general/activation.json')
end

local function _rollForJunk()
    local total = 0
    for _, rate in pairs(_junk) do
        total = total + rate
    end
    local randomRoll = math.random() * total
    for key, rate in pairs(_junk) do
        randomRoll = randomRoll - rate
        if total <= 0 then
            return key
        end
    end
    return 'rock'
end

local function _calculateConversionChance()
    return sackOfJunk.data.amount + (game.control.luck * 0.1)
end

function sackOfJunk.getVar(variableName)
    if variableName == 'amount' then
        return _calculateConversionChance()
    end
    return nil
end

function sackOfJunk.pump(pumpData)
    local roll = math.random()
    if roll > _calculateConversionChance() * 0.01 then
        return
    end
    _tryReplace()
    table.insert(pumpData.pumpers, sackOfJunk)
end

function sackOfJunk.onRemoveTile(item)
    if not _wasSold then
        return
    end
    _wasSold = false
    if item.subtype == 'junk' then
        return
    end
    local junkKey = _rollForJunk()
    game.control.tiles.setFirstOpenSlot(_data.tiles[junkKey])
    game.control.ui.triggerTile(sackOfJunk.index, true)
end

function sackOfJunk.onSellTile(_)
    _wasSold = true
end

return sackOfJunk
