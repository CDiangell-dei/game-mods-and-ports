local shopRoller = {}

local _data = require('data/scripts/data.lua')
local _minRarity = 0

local function _getLegendaryWeight()
    local stage = game.control.getFloorCount()
    if stage < 10 then
        return 0
    end
    local weight = (stage - 9) * (0.003 + (game.control.luck * 0.001))
    if weight < 0 then
        weight = 0
    end
    return weight
end

local function _getEpicWeight()
    local stage = game.control.getFloorCount()
    if stage < 5 then
        return 0
    end
    local weight = (stage - 4) * (0.01 + (game.control.luck * 0.001))
    if weight < 0 then
        weight = 0
    end
    return weight
end

local function _getRareWeight()
    local stage = game.control.getFloorCount()
    if stage < 3 then
        return 0.15 --More than 0 for early elites
    end
    local weight = (stage - 2) * (0.03 + (game.control.luck * 0.001)) + 0.15
    if weight < 0 then
        weight = 0
    end
    return weight
end

local function _getCommonWeight()
    return 1.0
end

local function _isLocked(item)
    if item.requiredTriggers == nil then
        return false
    end
    for _, v in ipairs(item.requiredTriggers) do
        local point = game.data.getProgress(v.id)
        if point ~= v.value then
            return true
        end
    end
    return false
end

local function _isExcluded(key, item)
    if item.subtype == 'junk' then
        return true
    end
    if item.limit < 1 then
        return _isLocked(item)
    end
    local count = 0
    local tileCount = game.control.tiles.getCount()
    for i=1, tileCount do
        local tile = game.control.tiles.getTile(i)
        if tile ~= nil and tile.data.key == key then
            count = count + 1
            if count >= item.limit then
                return true
            end
        end
    end
    return _isLocked(item)
end

local function _calculateItemWeight(item)
    if item.rarity < _minRarity then
        return 0
    end
    if item.rarity == 4 then
        return _getLegendaryWeight()
    elseif item.rarity == 3 then
        return _getEpicWeight()
    elseif item.rarity == 2 then
        return _getRareWeight()
    else
        return _getCommonWeight()
    end
end

local function _getItemFromWeight(weight)
    local latestV = nil
    local currentWeight = 0
    for k, v in pairs(_data.tiles) do
        if not _isExcluded(k, v) then
            currentWeight = currentWeight + _calculateItemWeight(v)
            if currentWeight >= weight then
                return v
            end
            latestV = v
        end
    end
    return latestV
end

local function _calculateTotalWeight()
    local weight = 0
    for k, v in pairs(_data.tiles) do
        if not _isExcluded(k, v) then
            weight = weight + _calculateItemWeight(v)
        end
    end
    return weight
end

local function _setMinimumRarity(isElite)
    if not isElite then
        return
    end
    local floor = game.control.getFloorCount()
    if floor >= 10 then
        _minRarity = 3
    else
        _minRarity = 2
    end
end

function shopRoller.getRandomItem(isElite)
    _setMinimumRarity(isElite)
    local totalWeight = _calculateTotalWeight()
    local roll = math.random()
    local weight = roll * totalWeight
    return _getItemFromWeight(weight)
end

return shopRoller
