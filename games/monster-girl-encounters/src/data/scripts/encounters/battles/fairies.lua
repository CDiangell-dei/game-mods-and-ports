local fairies = {}

local _ui
local _battle
local _timer = dofile('data/scripts/encounters/battles/battle_timer.lua')
local _pumpingComplete = false

--PHASE 2

function fairies.completeWin()
    _pumpingComplete = true
    if game.control ~= nil and game.control.lives ~= nil and game.control.maxLives ~= nil then
        while game.control.lives < game.control.maxLives do
            game.control.gainLife()
        end
    end
    _battle.complete(0, nil)
end

local function _enterWinOutro2()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/fairies/win_3/data.json')
    local function startDialogue()
        fairies.losePumping()
        _ui.spawnDialogue('data/dialogue/fairies/win_2_1.json', false, nil)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _enterLoseOutro2()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/fairies/loss_2a/data.json')
    local function startDialogue()
        fairies.losePumping()
        _ui.spawnDialogue('data/dialogue/fairies/loss_2_1.json', false, nil)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _completeBattle2()
    _battle.stopBattle()
    local cum = dofile('data/scripts/general/cum_outside.lua')
    local isFail = _battle.exhaustion < _battle.requiredExhaustion
    local onComplete
    if isFail then
        onComplete = function()
            if _battle.shouldSkipOutro(true) then
                _battle.complete()
            else
                game.control.ui.fadeToWhite(_enterLoseOutro2)
            end
        end
    else
        onComplete = function()
            if _battle.shouldSkipOutro(false) then
                fairies.completeWin()
            else
                game.control.ui.fadeToWhite(_enterWinOutro2)
            end
        end
    end
    cum(onComplete)
end

local function _initPhase2()
    _timer.events = {}

    table.insert(_timer.events, {
        loops = 1,
        action = function()
            _ui.setBackground('data/sprites/dither/0.png')
            _ui.setSprite('data/animations/fairies/2/data.json')
            _ui.setAnimatorSpeed(1.0)
            _ui.setLoopsPerPump(1)
        end,
    })
    table.insert(_timer.events, {
        loops = 8,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_1.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 8,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_2.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 10,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_3.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 6,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_4.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 8,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_5.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 6,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_6.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 6,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_7.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 3,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_8.json', true, nil)
            _ui.setAnimatorSpeed(1.1)
        end,
    })
    table.insert(_timer.events, {
        loops = 3,
        action = function()
            _ui.setAnimatorSpeed(1.2)
        end,
    })
    table.insert(_timer.events, {
        loops = 2,
        action = function()
            _ui.setAnimatorSpeed(1.3)
        end,
    })
    table.insert(_timer.events, {
        loops = 2,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_9a.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 2,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_9.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 2,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_10.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 3,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_2_11.json', true, nil)
        end,
    })
end

local function _startPhase2()
    local pumpCount = 70.0 * 1.75 --determined from events
    _battle.startBattle(pumpCount)
    _initPhase2()
    _timer.init()
    _timer.setOnComplete(_completeBattle2)
    game.control.ui.fadeIn(nil)
end

function fairies.preparePhase2()
    _pumpingComplete = true
    local function waitThenStartBattle()
        game.audio.playSound('data/sounds/general/start_battle.json')
        game.timer.queue(1.5, _startPhase2)
    end
    game.control.ui.fadeToBlack(waitThenStartBattle)
end

local function _intro2()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/fairies/win_1/data.json')
    local function startDialogue()
        fairies.losePumping()
        _ui.spawnDialogue('data/dialogue/fairies/win_1_1.json', false, nil)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

--PHASE 1

function fairies.losePumping()
    _pumpingComplete = false
    local _isUp = true
    local function soundLoop()
        if _pumpingComplete then
            return
        end
        _isUp = not _isUp
        if _isUp then
            game.audio.playSound('data/sounds/sex/rub_up.json')
        else
            game.audio.playSound('data/sounds/sex/rub_down.json')
        end
        game.timer.queueScaled(1.5, soundLoop)
    end
    soundLoop()
end

function fairies.callBattleComplete()
    _pumpingComplete = true
    _battle.complete()
end

local function _enterLoseOutro1()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/fairies/loss_1a/data.json')
    local function startDialogue()
        fairies.losePumping()
        _ui.spawnDialogue('data/dialogue/fairies/loss_1_1.json', false, nil)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _completeBattle1()
    _battle.stopBattle()
    local cum = dofile('data/scripts/general/cum_outside.lua')
    local isFail = _battle.exhaustion < _battle.requiredExhaustion
    local onComplete
    if isFail then
        onComplete = function()
            if _battle.shouldSkipOutro(true) then
                _battle.complete()
            else
                game.control.ui.fadeToWhite(_enterLoseOutro1)
            end
        end
    else
        onComplete = function()
            if _battle.shouldSkipOutro(false) then
                fairies.preparePhase2()
            else
                game.control.ui.fadeToWhite(_intro2)
            end
        end
    end
    cum(onComplete)
end

local _pendingEvents = {}

local function _addEvent(event)
    table.insert(_pendingEvents, event)
end

local function _updateBattleAnimation(index)
    local phase = index % 3
    if phase == 0 then
        _ui.setSprite('data/animations/fairies/1a/data.json')
    elseif phase == 1 then
        _ui.setSprite('data/animations/fairies/1b/data.json')
    else
        _ui.setSprite('data/animations/fairies/1c/data.json')
    end
end

local function _processEvents()
    local total = 0
    for i=1, #_pendingEvents do
        local loops = _pendingEvents[i].loops
        total = total + loops
    end
    local index = 0
    for i=1, #_pendingEvents do
        index = index + 1
        local eventAction = _pendingEvents[i].action
        local current = index
        table.insert(_timer.events, {
            loops = 1,
            action = function()
                _updateBattleAnimation(current)
                if eventAction ~= nil then
                    eventAction()
                end
            end,
        })
        for j=2, _pendingEvents[i].loops do
            index = index + 1
            local next = index
            table.insert(_timer.events, {
                loops = 1,
                action = function()
                    _updateBattleAnimation(next)
                end,
            })
        end
    end
    _pendingEvents = {}
end

local function _initPhase1()
    _addEvent({
        loops = 2,
        action = function()
            _ui.setBackground('data/sprites/dither/0.png')
            _ui.setAnimatorSpeed(1.0)
            _ui.setLoopsPerPump(1)
        end,
    })
    _addEvent({
        loops = 10,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_1_1.json', true, nil)
        end,
    })
    _addEvent({
        loops = 10,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_1_2.json', true, nil)
        end,
    })
    _addEvent({
        loops = 8,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_1_3.json', true, nil)
        end,
    })
    _addEvent({
        loops = 5,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_1_4.json', true, nil)
        end,
    })
    _addEvent({
        loops = 3,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_1_5.json', true, nil)
        end,
    })
    _addEvent({
        loops = 2,
        action = function()
            _ui.setAnimatorSpeed(1.1)
        end,
    })
    _addEvent({
        loops = 2,
        action = function()
            _ui.setAnimatorSpeed(1.25)
        end,
    })
    _addEvent({
        loops = 10,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_1_6.json', true, nil)
        end,
    })
    _addEvent({
        loops = 3,
        action = function()
            _ui.spawnDialogue('data/dialogue/fairies/battle_1_7.json', true, nil)
        end,
    })
    _addEvent({
        loops = 3,
        action = function()
            _ui.setAnimatorSpeed(1.3)
        end,
    })
    _addEvent({
        loops = 3,
        action = function()
            _ui.setAnimatorSpeed(1.4)
        end,
    })
    _addEvent({
        loops = 4,
        action = function()
            _ui.setAnimatorSpeed(1.5)
        end,
    })
    _processEvents()
end

local function _startPhase1()
    local pumpCount = 65.0 * 1.5 --determined from events
    _battle.startBattle(pumpCount)
    _initPhase1()
    _timer.init()
    _timer.setOnComplete(_completeBattle1)
    game.control.ui.fadeIn(nil)
end

function fairies.prepareBattle1()
    local function waitThenStartBattle()
        game.audio.playSound('data/sounds/general/start_battle.json')
        game.timer.queue(1.5, _startPhase1)
    end
    game.control.ui.fadeToBlack(waitThenStartBattle)
end

local function _startIntro1()
    _ui.spawnDialogue('data/dialogue/fairies/intro.json', false, nil)
end

local function _reduceHealth()
    local data = require('data/scripts/data.lua')
    local doll = data.tiles['doll']
    local lifegem = data.tiles['lifegem']
    local function process(x, y)
        local index = game.control.tiles.getIndex(x, y)
        local tile = game.control.tiles.getTile(index)
        if tile == nil then
            return
        end
        if tile.data == doll then
            game.control.tiles.setTile(index, data.tiles['doll_off'])
        end
        if tile.data == lifegem then
            game.control.tiles.setTile(index, data.tiles['lifegem_off'])
        end
    end

    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()

    for x = 1, width do
        for y = 1, height do
            process(x, y)
        end
    end

    game.control.shield = 0
    while game.control.lives > 1 do
        game.control.loseLife()
    end
end

function fairies.init()
    _battle = game.control.encounter
    _battle.isElite = true

    _ui = game.control.encounter.ui
    game.audio.playMusic('data/sounds/enchanted_forest.json')
    if _battle.shouldSkipIntro() then
        _reduceHealth()
        _startPhase1()
    else
        _ui.setBackground('data/sprites/encounters/fairies_bg.png')
        _ui.setSprite('data/sprites/dither/0.png')
        game.control.ui.fadeIn(_startIntro1)
    end
end

return fairies
