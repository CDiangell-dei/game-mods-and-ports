local scenarioRandomizer = {}

local _data = require('data/scripts/data.lua')
local _usedShops = {}
local _usedBattles = {}
local _usedEliteBattles = {}
local _usedBossBattles = {}
local _usedRandomEncounters = {}
local _iterator = 0

local function _clearTableOfNonUnique(data, used)
    for k, _ in pairs(used) do
        local encounter = data[k]
        if encounter ~= nil and encounter.isUnique ~= true then
            used[k] = nil
        end
    end
end

local function _isLocked(encounter)
    if encounter.requiredTriggers == nil then
        return false
    end
    for _, v in ipairs(encounter.requiredTriggers) do
        local point = game.data.getProgress(v.id)
        if point ~= v.value then
            return true
        end
    end
    return false
end

local function _cannotRoll(k, v, usedTable, floorCount)
    if usedTable[k] ~= nil then
        return true
    end
    if v.minFloor ~= nil and v.minFloor > floorCount then
        return true
    end
    if v.maxFloor ~= nil and v.maxFloor < floorCount then
        return true
    end
    return _isLocked(v)
end

local function _getTotalWeight(data, usedTable, floorCount)
    local weight = 0
    for k, v in pairs(data) do
        if _cannotRoll(k, v, usedTable, floorCount) == false then
            if v.weight == nil then
                weight = weight + 1.0
            else
                weight = weight + v.weight
            end
        end
    end
    if weight <= 0 then
        if _iterator > 0 then
            error('No available non-unique scenarios remaining.')
        end
        _iterator = _iterator + 1
        _clearTableOfNonUnique(data, usedTable)
        return _getTotalWeight(data, usedTable, floorCount)
    end
    return weight
end

local function _roll(data, usedTable, floorCount)
    _iterator = 0
    local totalWeight = _getTotalWeight(data, usedTable, floorCount)
    local weight = math.random() * totalWeight
    local final = nil
    for k, v in pairs(data) do
        if _cannotRoll(k, v, usedTable, floorCount) == false then
            if v.weight == nil then
                weight = weight - 1.0
            else
                weight = weight - v.weight
            end
            if weight <= 0 then
                return k
            end
            final = k
        end
    end
    return final
end

local function _getRandomEncounter(floorCount)
    local key = _roll(_data.randomEncounters, _usedRandomEncounters, floorCount)
    _usedRandomEncounters[key] = 1
    return _data.randomEncounters[key]
end

local function _getRandomShop(floorCount)
    local key = _roll(_data.shopEncounters, _usedShops, floorCount)
    _usedShops[key] = 1
    return _data.shopEncounters[key]
end

local function _getRandomBattle(floorCount)
    local key = _roll(_data.battleEncounters, _usedBattles, floorCount)
    _usedBattles[key] = 1
    return _data.battleEncounters[key]
end

local function _getRandomElite(floorCount)
    local key = _roll(_data.eliteEncounters, _usedEliteBattles, floorCount)
    _usedEliteBattles[key] = 1
    return _data.eliteEncounters[key]
end

local function _getRandomBoss(floorCount)
    local key = _roll(_data.bossEncounters, _usedBossBattles, floorCount)
    _usedBossBattles[key] = 1
    return _data.bossEncounters[key]
end

local function _getEncounterType(typeIndex)
    if typeIndex == 1 then
        return 'randomEncounter'
    elseif typeIndex == 2 then
        return 'elite'
    elseif typeIndex == 3 then
        return 'battle'
    else
        return 'shop'
    end
end

-- MOD (save/continue): which encounters were already used (so they do not repeat after loading)
local function _keysOf(used)
    local list = {}
    for k, _ in pairs(used) do
        table.insert(list, k)
    end
    return list
end

local function _fillFrom(used, list)
    for k, _ in pairs(used) do
        used[k] = nil
    end
    for _, k in ipairs(list or {}) do
        used[k] = 1
    end
end

function scenarioRandomizer.captureUsed()
    return {
        shops = _keysOf(_usedShops),
        battles = _keysOf(_usedBattles),
        elites = _keysOf(_usedEliteBattles),
        bosses = _keysOf(_usedBossBattles),
        randoms = _keysOf(_usedRandomEncounters),
    }
end

function scenarioRandomizer.restoreUsed(state)
    if state == nil then
        return
    end
    _fillFrom(_usedShops, state.shops)
    _fillFrom(_usedBattles, state.battles)
    _fillFrom(_usedEliteBattles, state.elites)
    _fillFrom(_usedBossBattles, state.bosses)
    _fillFrom(_usedRandomEncounters, state.randoms)
end

function scenarioRandomizer.getRandomEncounterType(exceptions)
    local roll = math.random()
    local typeIndex = 0
    while roll > 0 do
        roll = roll - 0.25
        typeIndex = typeIndex + 1
    end
    for _=1, 4 do
        local type = _getEncounterType(typeIndex)
        if exceptions == nil then
            return type
        end
        if exceptions[type] == nil then
            return type
        end
        typeIndex = typeIndex + 1
        if typeIndex > 4 then
            typeIndex = 1
        end
    end
    return _getEncounterType(typeIndex)
end

function scenarioRandomizer.getRandomEncounter(floorCount, type)
    if type == 'randomEncounter' then
        return _getRandomEncounter(floorCount)
    elseif type == 'boss' then
        return _getRandomBoss(floorCount)
    elseif type == 'elite' then
        return _getRandomElite(floorCount)
    elseif type == 'battle' then
        return _getRandomBattle(floorCount)
    else
        return _getRandomShop(floorCount)
    end
end

local function _getTableForType(encounterType)
    if encounterType == 'battle' then
        return _data.battleEncounters, _usedBattles
    elseif encounterType == 'elite' then
        return _data.eliteEncounters, _usedEliteBattles
    elseif encounterType == 'boss' then
        return _data.bossEncounters, _usedBossBattles
    elseif encounterType == 'shop' then
        return _data.shopEncounters, _usedShops
    elseif encounterType == 'randomEncounter' then
        return _data.randomEncounters, _usedRandomEncounters
    end
    return nil, nil
end

function scenarioRandomizer.markEncounterUsed(encounterType, key)
    if key == nil then
        return
    end
    local _, usedTable = _getTableForType(encounterType)
    if usedTable ~= nil then
        usedTable[key] = 1
    end
end

function scenarioRandomizer.peekEncounter(floorCount, encounterType, excludeKey)
    local data, usedTable = _getTableForType(encounterType)
    if data == nil then
        return nil
    end

    local candidates = {}
    for k, v in pairs(data) do
        if k ~= excludeKey and _cannotRoll(k, v, usedTable, floorCount) == false then
            table.insert(candidates, { key = k, encounter = v, weight = v.weight or 1.0 })
        end
    end

    if #candidates == 0 then
        for k, v in pairs(data) do
            if _cannotRoll(k, v, usedTable, floorCount) == false then
                table.insert(candidates, { key = k, encounter = v, weight = v.weight or 1.0 })
            end
        end
    end

    if #candidates == 0 then
        for k, v in pairs(data) do
            if v.isUnique ~= true then
                table.insert(candidates, { key = k, encounter = v, weight = v.weight or 1.0 })
            end
        end
    end

    if #candidates == 0 then
        for k, v in pairs(data) do
            table.insert(candidates, { key = k, encounter = v, weight = 1.0 })
        end
    end

    if #candidates == 0 then
        return nil
    end

    local totalWeight = 0
    for _, c in ipairs(candidates) do
        totalWeight = totalWeight + c.weight
    end
    local roll = math.random() * totalWeight
    for _, c in ipairs(candidates) do
        roll = roll - c.weight
        if roll <= 0 then
            return c.encounter
        end
    end
    return candidates[#candidates].encounter
end

return scenarioRandomizer
