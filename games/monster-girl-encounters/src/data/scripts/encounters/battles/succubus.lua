local succubus = {}

local _ui
local _battle
local _timer = dofile('data/scripts/encounters/battles/battle_timer.lua')
local _profit = 0
local _loseComplete = false

--PHASE 2

local function _completeWin()
    local progress = _battle.exhaustion / _battle.requiredExhaustion
    local profit = progress * 10.0
    profit = math.floor(profit) + _profit
    _battle.complete(profit, nil)
end

local function _enterWinOutro2()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/succubus/win2/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/succubus/win2.json', false, _completeWin)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

function succubus.losePumping2()
    local _isUp = true
    local function soundLoop()
        if _loseComplete then
            return
        end
        _isUp = not _isUp
        if _isUp then
            game.audio.playSound('data/sounds/sex/rub_up.json')
        else
            game.audio.playSound('data/sounds/sex/rub_down.json')
        end
        game.timer.queueScaled(1.0, soundLoop)
    end
    soundLoop()
end

local function _enterLoseOutro2()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/succubus/loss2_1/data.json')
    local function startDialogue()
        succubus.losePumping2()
        _ui.spawnDialogue('data/dialogue/succubus/loss2_1.json', false, nil)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _completeBattle2()
    _battle.stopBattle()
    local cum = dofile('data/scripts/general/cum_inside.lua')
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
                _completeWin()
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
            _ui.setSprite('data/animations/succubus/2/data.json')
            _ui.setAnimatorSpeed(1.0)
            _ui.setLoopsPerPump(1)
        end,
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle2_1.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle2_2.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle2_3.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle2_4.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle2_5.json', true, nil)
            _ui.setAnimatorSpeed(1.1)
        end,
    })
    table.insert(_timer.events, {
        loops = 6,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle2_6.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 4,
        action = function()
            _ui.setAnimatorSpeed(1.25)
        end,
    })
    table.insert(_timer.events, {
        loops = 8,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle2_7.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 2,
        action = function()
            _ui.setAnimatorSpeed(0.5)
        end,
    })
    table.insert(_timer.events, {
        loops = 2,
        action = function()
            _ui.setAnimatorSpeed(1.0)
        end,
    })
    table.insert(_timer.events, {
        loops = 2,
        action = function()
            _ui.setAnimatorSpeed(1.25)
        end,
    })
    table.insert(_timer.events, {
        loops = 8,
        action = function()
            _ui.setAnimatorSpeed(1.5)
        end,
    })
end

local function _startPhase2()
    local pumpCount = 93.0 * 1.5 --determined from events
    _battle.startBattle(pumpCount)
    _initPhase2()
    _timer.init()
    _timer.setOnComplete(_completeBattle2)
    game.control.ui.fadeIn(nil)
end

local function _preparePhase2()
    local function waitThenStartBattle()
        game.audio.playSound('data/sounds/general/start_battle.json')
        game.timer.queue(1.5, _startPhase2)
    end
    game.control.ui.fadeToBlack(waitThenStartBattle)
end

local function _intro2()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/succubus/win1/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/succubus/win1.json', false, _preparePhase2)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

--PHASE 1

function succubus.losePumping1()
    local function soundLoop()
        if _loseComplete then
            return
        end
        dofile('data/scripts/general/bj_sound.lua')
        game.timer.queueScaled(0.5, soundLoop)
    end
    soundLoop()
end

function succubus.callBattleComplete()
    _loseComplete = true
    _battle.complete()
end

local function _enterLoseOutro1()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/succubus/loss1/data.json')
    local function startDialogue()
        succubus.losePumping1()
        _ui.spawnDialogue('data/dialogue/succubus/loss1_1.json', false, nil)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _calculateProfit1()
    local progress = _battle.exhaustion / _battle.requiredExhaustion
    local profit = progress * 10.0
    _profit = _profit + math.floor(profit)
end

local function _completeBattle1()
    _battle.stopBattle()
    local cum = dofile('data/scripts/general/cum_inside.lua')
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
        _calculateProfit1()
        onComplete = function()
            if _battle.shouldSkipOutro(false) then
                _preparePhase2()
            else
                game.control.ui.fadeToWhite(_intro2)
            end
        end
    end
    cum(onComplete)
end

local function _initPhase1()
    table.insert(_timer.events, {
        loops = 2,
        action = function()
            _ui.setBackground('data/sprites/dither/0.png')
            _ui.setSprite('data/animations/succubus/1/data.json')
            _ui.setAnimatorSpeed(1.0)
            _ui.setLoopsPerPump(1)
        end,
    })
    table.insert(_timer.events, {
        loops = 10,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle1_1.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 6,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle1_2.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 6,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle1_3.json', true, nil)
        end,
    })
    table.insert(_timer.events, {
        loops = 10,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle1_4.json', true, nil)
            _ui.setAnimatorSpeed(1.15)
        end,
    })
    table.insert(_timer.events, {
        loops = 7,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle1_5.json', true, nil)
            _ui.setAnimatorSpeed(1.2)
        end,
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle1_6.json', true, nil)
            _ui.setAnimatorSpeed(1.25)
        end,
    })
    table.insert(_timer.events, {
        loops = 4,
        action = function()
            _ui.spawnDialogue('data/dialogue/succubus/battle1_7.json', true, nil)
            _ui.setAnimatorSpeed(1.35)
        end,
    })
    table.insert(_timer.events, {
        loops = 6,
        action = function()
            _ui.setAnimatorSpeed(1.5)
        end,
    })
    table.insert(_timer.events, {
        loops = 2,
        action = function()
            _ui.setAnimatorSpeed(1.75)
        end,
    })
    table.insert(_timer.events, {
        loops = 2,
        action = function()
            _ui.setAnimatorSpeed(2.0)
        end,
    })
end

local function _startPhase1()
    local pumpCount = 67.0 * 1.25 --determined from events
    _battle.startBattle(pumpCount)
    _initPhase1()
    _timer.init()
    _timer.setOnComplete(_completeBattle1)
    game.control.ui.fadeIn(nil)
end

function succubus.prepareBattle1()
    local function waitThenStartBattle()
        game.audio.playSound('data/sounds/general/start_battle.json')
        game.timer.queue(1.5, _startPhase1)
    end
    game.control.ui.fadeToBlack(waitThenStartBattle)
end

local function _startIntro1()
    _ui.spawnDialogue('data/dialogue/succubus/intro.json', false, succubus.prepareBattle1)
end

function succubus.init()
    _battle = game.control.encounter
    _battle.isElite = true
    _ui = game.control.encounter.ui
    game.audio.playMusic('data/sounds/ambient1.json')
    if _battle.shouldSkipIntro() then
        _startPhase1()
    else
        _ui.setBackground('data/sprites/encounters/succubus_bg.png')
        _ui.setSprite('data/sprites/dither/0.png')
        game.control.ui.fadeIn(_startIntro1)
    end
end

return succubus
