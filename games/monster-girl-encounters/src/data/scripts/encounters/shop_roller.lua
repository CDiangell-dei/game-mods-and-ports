local shopRoller = {}

local _data = require('data/scripts/data.lua')
local _modifiers

local function _getLegendaryWeight()
    local stage = game.control.getFloorCount()
    local modifier = 0.05 + (game.control.luck * 0.005)
    modifier = math.max(modifier, 0)
    local weight = (stage - 4) * modifier
    return math.max(weight, 0)
end

local function _getRareWeight()
    local stage = game.control.getFloorCount()
    local modifier = 0.35 + (game.control.luck * 0.005)
    modifier = math.max(modifier, 0)
    local weight = (stage - 2) * modifier
    return math.max(weight, 0)
end

local function _getUncommonWeight()
    local stage = game.control.getFloorCount()
    local modifier = 0.25 + (game.control.luck * 0.005)
    modifier = math.max(modifier, 0)
    return (stage * modifier) + 0.15
end

local function _getCommonWeight()
    return 1.0
end

local function _arrayContains(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

local function _isLocked(item)
    if item.requiredTriggers == nil or _modifiers.forceUnlock then
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

local function _isExcludedByModifiers(key, item)
    if item.subtype == 'junk' then
        return true
    end
    if _modifiers == nil then
        return false
    end
    if _modifiers.requiredRarity ~= nil then
        if not _arrayContains(_modifiers.requiredRarity, item.rarity) then
            return true
        end
    end
    if _modifiers.requiredSpecific ~= nil then
        if not _arrayContains(_modifiers.requiredSpecific, key) then
            return true
        end
    end
    if _modifiers.excludedSpecific ~= nil then
        if _arrayContains(_modifiers.excludedSpecific, key) then
            return true
        end
    end
    return false
end

local function _isExcluded(key, item)
    if _isExcludedByModifiers(key, item) then
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
    if item.rarity == 4 then
        return _getLegendaryWeight()
    elseif item.rarity == 3 then
        return _getRareWeight()
    elseif item.rarity == 2 then
        return _getUncommonWeight()
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

function shopRoller.getRandomItem(modifiers)
    _modifiers = modifiers
    local totalWeight = _calculateTotalWeight()
    local roll = math.random()
    local weight = roll * totalWeight
    return _getItemFromWeight(weight)
end

shopRoller.getCommonWeight = _getCommonWeight
shopRoller.getUncommonWeight = _getUncommonWeight
shopRoller.getRareWeight = _getRareWeight
shopRoller.getLegendaryWeight = _getLegendaryWeight

return shopRoller
