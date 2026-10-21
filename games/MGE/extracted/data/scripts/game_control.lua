local control = {
    persistent = {}, --use for storing various data kept between encounters
    luck = 0,
    lives = 3,
    shield = 0,
    maxLives = 3,
    tiles = dofile('data/scripts/tiles_holder.lua'),
    buffs = dofile('data/scripts/buffs_holder.lua'),
    ui = dofile('data/scripts/ui/game_main.lua'),
    maxFloors = 13,
    fixedEncounters = {
        [13] = 'boss_fairies',
        --[1] = 'shop_1',
        --[2] = 'boss_fairies',
        --[1] = 'random_hotspring',
        --[1] = 'random_spirit',
    },
    encounterScripts = {
        battle = 'data/scripts/encounters/battle.lua',
        elite = 'data/scripts/encounters/battle.lua',
        boss = 'data/scripts/encounters/battle.lua',
        shop = 'data/scripts/encounters/shop.lua',
    },
    encounterType = '',
}

local _selector = dofile('data/scripts/scenario_selector.lua')
local _mods = require('mods/mod_manager.lua') -- MOD
local _runSave = require('data/scripts/run_save.lua') -- MOD (save/continue)
local _awaitingSelection = false -- MOD (save/continue): true while the map is waiting for a branch pick
local _gold = 0
local _triggerReceivers = {}
local _pendingRemovals = nil
local _forcedEncounter = nil
local _encounterCount = 0
local _seed = 0

local function _spawnNextEncounter()
    game.audio.stopMusic()
    local encounterType = control.encounterData.type
    control.encounterType = encounterType
    if control.encounterScripts[encounterType] ~= nil then
        control.encounter = dofile(control.encounterScripts[encounterType])
        if control.encounterData.script ~= nil then
            control.encounter.script = dofile(control.encounterData.script)
        end
    else
        control.encounter = dofile(control.encounterData.script)
    end
    if control.encounter.init ~= nil then
        control.encounter.init()
    end
    if control.encounter.script ~= nil and control.encounter.script.init ~= nil then
        control.encounter.script.init()
    end
    control.trigger('onEnterEncounter', control.encounterData.type)
end

local function _completeRemoveReciever(receiver)
    for i, v in ipairs(_triggerReceivers) do
        if v == receiver then
            table.remove(_triggerReceivers, i)
            return
        end
    end
end

local function _removePendingReceivers()
    if _pendingRemovals == nil then
        return
    end
    for _, v in pairs(_pendingRemovals) do
        _completeRemoveReciever(v)
    end
    _pendingRemovals = nil
end

local function _update()
    local deltaTime = game.timer.getDeltaTime()
    control.trigger('update', deltaTime)
    control.ui.update(deltaTime)
end

local function _clearEncounter()
    if control.encounter ~= nil then
        local encounter = control.encounter
        control.encounter = nil
        control.trigger('onExitEncounter')
        if encounter.script ~= nil and encounter.script.onDestroy ~= nil then
            encounter.script.onDestroy()
        end
        if encounter.onDestroy ~= nil then
            encounter.onDestroy()
        end
        control.ui.closeDialogue()
        control.ui.cancelFade()
    end
end

-- MOD (save/continue): saves a checkpoint, but only while the player is still choosing the
-- next encounter (so the save always points at a clean decision point)
local function _checkpoint()
    if _awaitingSelection then
        _runSave.save()
    end
end

local function _copyPlain(source)
    local copy = {}
    if type(source) ~= 'table' then
        return copy
    end
    for k, v in pairs(source) do
        local t = type(v)
        if t == 'number' or t == 'string' or t == 'boolean' then
            copy[k] = v
        end
    end
    return copy
end

local function _enterEndScene()
    _awaitingSelection = false
    _runSave.clear() -- MOD (save/continue): the run is over, nothing to continue
    local function complete()
        control.trigger('onExitGame')
        _clearEncounter()
        game.events.unsubscribe('update', _update)
        control.ui.destroy()
        dofile('data/scripts/ui/end_scene.lua')
    end
    game.scene.fadeToBlack(1.5, complete)
    game.audio.stopMusic()
end

local function _collectLoserReward()
    local data = require('data/scripts/data.lua')
    local buff = data.buffs['determination']
    game.control.buffs.add(buff)
    local level = game.control.getFloorCount()
    local profit = (0.5 + (level * 0.2)) * 10
    game.control.gainGold(profit)
    game.audio.playSound('data/sounds/general/purchase.json')
    control.ui.fadeToTransition(control.completeEncounter)
end

local function _startLoserDialogue()
    game.control.encounter.ui.spawnDialogue('data/dialogue/lose_battle.json', false, _collectLoserReward)
    --control.ui.spawnDialogue('data/dialogue/lose_battle.json', _collectLoserReward, false)
end

local function _completeEndGame()
    if control.lives > 0 then
        control.ui.fadeToBlack(_startLoserDialogue)
        return
    end
    _enterEndScene()
end

function control.init(onIntroComplete)
    -- MOD: mods can change the floor limit (endless_mode returns math.huge)
    control.maxFloors = _mods.filter('maxFloors', 13)
    _selector.init(control.fixedEncounters)
    control.ui.instantiate(onIntroComplete or control.completeEncounter)
    game.events.subscribe('update', _update)
    game.scene.fadeIn(0.5, nil)
end

function control.forceNextEncounter(key)
    _forcedEncounter = key
end

local function _subtractLife()
    if control.shield > 0 then
        control.shield = control.shield - 1
        return false
    end
    control.lives = control.lives - 1
    return true
end

function control.endGame()
    -- MOD: before a lost battle costs a life, tiles may absorb it (balance: lifegem).
    -- A shield (doll) is used first, so only ask when there is none.
    local absorb = { absorbed = false }
    if control.shield <= 0 then
        control.trigger('onBeforeLifeLoss', absorb)
    end
    if absorb.absorbed or not _subtractLife() then
        _completeEndGame()
        return
    end
    control.ui.loseLife(_completeEndGame)
end

function control.loseLife()
    if not _subtractLife() then
        return
    end
    control.ui.loseLifeFast()
    if control.lives <= 0 then
        _enterEndScene()
    end
end

function control.gainLife()
    if control.lives >= control.maxLives then
        return
    end
    control.lives = control.lives + 1
    control.ui.gainLife()
end

function control.isFinalFloor()
    return _encounterCount + 1 >= control.maxFloors
end

function control.completeEncounter()
    game.data.save()
    local wasBattle = false
    if control.encounterData ~= nil then
        if control.encounterData.type == 'battle' or control.encounterData.type == 'elite' or
            control.encounterData.type == 'boss' then
                wasBattle = true
        end
    end
    _clearEncounter()
    _encounterCount = _encounterCount + 1
    control.ui.setLevel(_encounterCount)
    if _encounterCount > control.maxFloors then
        local isStoryMode = game.data.getSetting('gameMode') < 0.5
        if isStoryMode and _encounterCount == 14 and wasBattle then
            local prompt = dofile('data/scripts/ui/endless_prompt.lua')
            prompt.init(
                function()
                    game.data.setProgress('standard_complete', 1)
                    game.data.setSetting('gameMode', 1)
                    control.maxFloors = math.huge
                    _selector.ensureEndlessTree()
                    local cycleReward = dofile('data/scripts/ui/cycle_reward.lua')
                    cycleReward.init(function()
                        local combining = false
                        _awaitingSelection = true
                        if wasBattle then
                            combining = control.tiles.combinePending(_checkpoint)
                        end
                        if _forcedEncounter ~= nil and _forcedEncounter ~= '' then
                            _selector.forceEncounter(_forcedEncounter)
                            _forcedEncounter = nil
                        end
                        control.ui.prepareEncounter(_selector.getEncounterTree())
                        if not combining then
                            _checkpoint()
                        end
                    end)
                end,
                function()
                    _enterEndScene()
                end
            )
            return
        end
        _enterEndScene()
        return
    end

    if wasBattle and (_encounterCount - 1) % 13 == 0 and _encounterCount > 1 then
        local cycleReward = dofile('data/scripts/ui/cycle_reward.lua')
        cycleReward.init(function()
            local combining = false
            _awaitingSelection = true
            if wasBattle then
                combining = control.tiles.combinePending(_checkpoint)
            end
            if _forcedEncounter ~= nil and _forcedEncounter ~= '' then
                _selector.forceEncounter(_forcedEncounter)
                _forcedEncounter = nil
            end
            control.ui.prepareEncounter(_selector.getEncounterTree())
            if not combining then
                _checkpoint()
            end
        end)
        return
    end

    local combining = false
    if wasBattle then
        combining = control.tiles.combinePending(_checkpoint)
    end
    if _forcedEncounter ~= nil and _forcedEncounter ~= '' then
        _selector.forceEncounter(_forcedEncounter)
        _forcedEncounter = nil
    end
    control.ui.prepareEncounter(_selector.getEncounterTree())
    _awaitingSelection = true
    if not combining then
        _checkpoint() -- MOD (save/continue)
    end
end

-- MOD (save/continue) ----------------------------------------------------
function control.captureRunState()
    return {
        floor = _encounterCount,
        gold = _gold,
        seed = _seed,
        lives = control.lives,
        maxLives = control.maxLives,
        shield = control.shield,
        luck = control.luck,
        forced = _forcedEncounter,
        persistent = _copyPlain(control.persistent),
        selector = _selector.captureState(),
    }
end

-- before control.init(): values the UI reads while it is being built
function control.restoreRunStatePreInit(state)
    control.lives = state.lives or control.lives
    control.maxLives = state.maxLives or control.maxLives
    control.persistent = _copyPlain(state.persistent)
    _seed = state.seed or 0
end

-- after control.init(): puts the floor counter and the map back where it was
function control.restoreRunStatePostInit(state)
    -- completeEncounter adds 1 and opens the map, so start one floor behind
    _encounterCount = math.max((state.floor or 1) - 1, 0)
    _forcedEncounter = state.forced
    _selector.restoreState(state.selector)
end

-- after tiles and buffs were rebuilt: overrides anything their init changed
function control.restoreRunValues(state)
    control.luck = state.luck or 0
    control.shield = state.shield or 0
    _gold = state.gold or 0
    control.ui.displayGold(_gold)
end
-- END MOD (save/continue) ------------------------------------------------

function control.selectEncounterBranch(isLeft)
    _awaitingSelection = false -- MOD (save/continue)
    control.encounterData = _selector.selectBranch(isLeft)
    control.ui.enterEncounter(_spawnNextEncounter)
end

function control.getFloorCount()
    return _encounterCount
end

function control.setSeed(seed)
    _seed = seed or 0
end

function control.getSeed()
    return _seed
end

function control.getGold()
    return _gold
end

-- MOD: the gold cap can be changed by mods (no_limit raises it)
function control.getMaxGold()
    return _mods.filter('maxGold', 999999)
end

function control.gainGold(amount)
    amount = _mods.filter('sanitizeNumber', amount, 'gold') -- MOD: keeps NaN/inf out of the gold
    if amount == 0 then
        return
    end
    _gold = _mods.filter('sanitizeNumber', _gold + amount, 'gold') -- MOD
    local maxGold = control.getMaxGold()
    if _gold > maxGold then
        _gold = maxGold
    end
    _mods.call('onGoldChanged', _gold) -- MOD: rastreia desbloqueios (mods/unlocks.lua)
    control.ui.displayGold(_gold)
    control.trigger('onGainGold', amount)
end

function control.loseGold(amount)
    amount = _mods.filter('sanitizeNumber', amount, 'gold') -- MOD
    if amount == 0 then
        return
    end
    _gold = _mods.filter('sanitizeNumber', _gold - amount, 'gold') -- MOD
    if _gold < 0 then
        amount = amount + _gold
        _gold = 0
    end
    control.ui.displayGold(_gold)
    control.trigger('onLoseGold', amount)
end

function control.trigger(event, ...)
    control.tiles.trigger(event, ...)
    control.buffs.trigger(event, ...)
    local count = #_triggerReceivers
    for i=1, count do
        local v = _triggerReceivers[i]
        if v ~= nil and v[event] ~= nil then
            v[event](...)
        end
    end
    _removePendingReceivers()
    if control.encounter == nil then
        return
    end
    local receiver = control.encounter.script
    if receiver ~= nil and receiver[event] ~= nil then
        receiver[event](...)
    end
    if control.encounter[event] ~= nil then
        control.encounter[event](...)
    end
end

function control.addTriggerReceiver(receiver)
    table.insert(_triggerReceivers, receiver)
end

function control.removeTriggerReceiver(receiver)
    if _pendingRemovals == nil then
        _pendingRemovals = {}
    end
    _pendingRemovals[receiver] = receiver
end

return control
