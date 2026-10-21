local scenarioSelector = {}

local _randomizer = require('data/scripts/scenario_randomizer.lua')
local _data = require('data/scripts/data.lua')
local _encounterTree = {
    floor = 0,
    type = 'default',
}
local _fixedEncounters

local function _getEncounter(key)
    if key == nil then
        return nil
    end
    if _data.battleEncounters[key] ~= nil then
        return _data.battleEncounters[key]
    end
    if _data.eliteEncounters[key] ~= nil then
        return _data.eliteEncounters[key]
    end
    if _data.bossEncounters[key] ~= nil then
        return _data.bossEncounters[key]
    end
    if _data.shopEncounters[key] ~= nil then
        return _data.shopEncounters[key]
    end
    if _data.randomEncounters[key] ~= nil then
        return _data.randomEncounters[key]
    end
    return nil
end

local function _setFixedBranch(fixed, node)
    node.left.type = fixed.type
    node.left.fixed = fixed
    node.right.type = fixed.type
    node.right.fixed = fixed
end

local function _setShop(node)
    node.left.type = 'shop'
    node.right.type = 'shop'
    local roll = math.random()
    if roll >= 0.85 then
        node.left.type = 'randomEncounter'
        return
    end
    roll = math.random()
    if roll >= 0.85 then
        node.right.type = 'randomEncounter'
    end
end

local function _setShopOnly(node)
    node.left.type = 'shop'
    node.right.type = 'shop'
end

local function _setBattle(node)
    node.left.type = 'battle'
    node.right.type = 'battle'
end

local function _setRandom(node)
    node.left.type = 'randomEncounter'
    node.right.type = 'randomEncounter'
end

local function _setPossibleElite(node)
    node.left.type = 'battle'
    node.right.type = 'battle'
    local roll = math.random()
    if roll >= 0.75 then
        node.left.type = 'elite'
        return
    end
    roll = math.random()
    if roll >= 0.75 then
        node.right.type = 'elite'
    end
end

local function _setAlwaysElite(node)
    node.left.type = 'battle'
    node.right.type = 'battle'
    local roll = math.random()
    if roll >= 0.5 then
        node.left.type = 'elite'
    else
        node.right.type = 'elite'
    end
end

local function _setBoss(node)
    --TODO => set to boss
    node.left.type = 'boss'
    node.right.type = 'boss'
end

local _encounterSets = {
    [1] = _setBattle,
    [2] = _setShopOnly,
    [3] = _setBattle,
    [4] = _setRandom,
    [5] = _setShop,
    [6] = _setBattle,
    [7] = _setShop,
    [8] = _setPossibleElite,
    [9] = _setRandom,
    [10] = _setShop,
    [11] = _setAlwaysElite,
    [12] = _setShop,
    [13] = _setBoss,
}

-- MOD: how many floors make up one "loop" of the encounter pattern (battle/shop/elite/boss layout).
local _cycleLength = 13

local function _addBranch(node)
    local nextFloor = node.floor + 1
    node.left = {
        floor = nextFloor,
    }
    node.right = {
        floor = nextFloor,
    }
    -- MOD: once we pass floor 13, wrap back around so the same pattern (and the boss fight)
    -- repeats every _cycleLength floors instead of running out of defined encounters.
    local cycleFloor = ((nextFloor - 1) % _cycleLength) + 1
    local fixed = _getEncounter(_fixedEncounters[nextFloor] or _fixedEncounters[cycleFloor])
    if fixed ~= nil then
        _setFixedBranch(fixed, node)
        node.left.encounter = fixed
        node.right.encounter = fixed
        return
    end
    if nextFloor > game.control.maxFloors then
        node.left.type = 'unknown'
        node.right.type = 'unknown'
    else
        _encounterSets[cycleFloor](node)
        node.left.encounter = _randomizer.peekEncounter(nextFloor, node.left.type)
        local exclude = node.left.encounter and node.left.encounter.key or nil
        node.right.encounter = _randomizer.peekEncounter(nextFloor, node.right.type, exclude)
    end
end

local function _generateEncounterTree()
    _addBranch(_encounterTree)
    _addBranch(_encounterTree.left)
    _addBranch(_encounterTree.right)
end

function scenarioSelector.init(fixedEncounters)
    _fixedEncounters = fixedEncounters
    _generateEncounterTree()
end

function scenarioSelector.getEncounterTree()
    return _encounterTree
end

function scenarioSelector.selectBranch(isLeft)
    if isLeft then
        _encounterTree = _encounterTree.left
    else
        _encounterTree = _encounterTree.right
    end
    _addBranch(_encounterTree.left)
    _addBranch(_encounterTree.right)
    if _encounterTree.fixed then
        return _encounterTree.fixed
    elseif _encounterTree.encounter then
        _randomizer.markEncounterUsed(_encounterTree.type, _encounterTree.encounter.key)
        return _encounterTree.encounter
    else
        return _randomizer.getRandomEncounter(_encounterTree.floor, _encounterTree.type)
    end
end

-- MOD (save/continue): the tree is saved as plain data (fixed encounters by key)
local function _serializeNode(node)
    if node == nil then
        return nil
    end
    local fixedKey = nil
    if node.fixed ~= nil then
        fixedKey = node.fixed.key
    end
    local encounterKey = nil
    if node.encounter ~= nil then
        encounterKey = node.encounter.key
    end
    return {
        floor = node.floor,
        type = node.type,
        fixed = fixedKey,
        encounterKey = encounterKey,
        left = _serializeNode(node.left),
        right = _serializeNode(node.right),
    }
end

local function _deserializeNode(data)
    if data == nil then
        return nil
    end
    local fixed = _getEncounter(data.fixed)
    local encounter = _getEncounter(data.encounterKey) or fixed
    return {
        floor = data.floor,
        type = data.type,
        fixed = fixed,
        encounter = encounter,
        left = _deserializeNode(data.left),
        right = _deserializeNode(data.right),
    }
end

function scenarioSelector.captureState()
    return {
        tree = _serializeNode(_encounterTree),
        used = _randomizer.captureUsed(),
    }
end

function scenarioSelector.restoreState(state)
    if state == nil or state.tree == nil then
        return false
    end
    _encounterTree = _deserializeNode(state.tree)
    _randomizer.restoreUsed(state.used)
    return true
end

function scenarioSelector.forceEncounter(key)
    local fixed = _getEncounter(key)
    if fixed == nil then
        return
    end
    _encounterTree.left.type = fixed.type
    _encounterTree.left.fixed = fixed
    _encounterTree.right.type = fixed.type
    _encounterTree.right.fixed = fixed
end

return scenarioSelector
