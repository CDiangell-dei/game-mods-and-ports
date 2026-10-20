local cyclops = {}

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

local function _winOutro()
    game.audio.playMusic('data/sounds/ambient1.json')
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/cyclops/outro_win/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/cyclops/outro_win.json', false, _completeWin)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

--PHASE 1

function cyclops.losePumping1()
    local function soundLoop()
        if _loseComplete then
            return
        end
        game.audio.playSound('data/sounds/sex/hard_plap_wet_quiet.json')
        game.timer.queueScaled(0.75, soundLoop)
    end
    soundLoop()
end

function cyclops.callBattleComplete()
    _loseComplete = true
    _battle.complete()
end

local function _enterLoseOutro1()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/cyclops/outro_loss/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/cyclops/outro_loss.json', false, nil)
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
                _completeWin()
            else
                game.control.ui.fadeToWhite(_winOutro)
            end
        end
    end
    cum(onComplete)
end

local function _updateBattleAnimation(count)
    local isEven = count % 2 == 0
    if isEven then
        _ui.setSprite('data/animations/cyclops/2/data.json')
    else
        _ui.setSprite('data/animations/cyclops/1/data.json')
    end
end

local function _initPhase1()
    for i=1, 75 do
        table.insert(_timer.events, {
            loops = 1,
            action = function()
                _updateBattleAnimation(i)
            end,
        })
    end
    _timer.events[1].action = function()
        _ui.setBackground('data/sprites/dither/0.png')
        _updateBattleAnimation(1)
        _ui.setAnimatorSpeed(0.75)
            _ui.setLoopsPerPump(1.0)
    end
    _timer.events[4].action = function()
        _updateBattleAnimation(4)
        _ui.spawnDialogue('data/dialogue/cyclops/battle1.json', true, nil)
    end
    _timer.events[15].action = function()
        _updateBattleAnimation(15)
        _ui.spawnDialogue('data/dialogue/cyclops/battle2.json', true, nil)
    end
    _timer.events[24].action = function()
        _updateBattleAnimation(24)
        _ui.setAnimatorSpeed(1.0)
    end
    _timer.events[33].action = function()
        _updateBattleAnimation(33)
        _ui.spawnDialogue('data/dialogue/cyclops/battle3.json', true, nil)
        _ui.setAnimatorSpeed(1.1)
    end
    _timer.events[39].action = function()
        _updateBattleAnimation(39)
        _ui.spawnDialogue('data/dialogue/cyclops/battle4.json', true, nil)
        _ui.setAnimatorSpeed(1.25)
    end
    _timer.events[51].action = function()
        _updateBattleAnimation(51)
        _ui.spawnDialogue('data/dialogue/cyclops/battle5.json', true, nil)
        _ui.setAnimatorSpeed(1.5)
    end
    _timer.events[60].action = function()
        _updateBattleAnimation(60)
        _ui.setAnimatorSpeed(1.75)
    end
end

local function _startPhase1()
    local pumpCount = 75.0 --determined from events
    _battle.startBattle(pumpCount)
    _initPhase1()
    _timer.init()
    _timer.setOnComplete(_completeBattle1)
    game.control.ui.fadeIn(nil)
end

function cyclops.prepareBattle1()
    local function waitThenStartBattle()
        game.audio.playSound('data/sounds/general/start_battle.json')
        game.timer.queue(1.5, _startPhase1)
    end
    game.control.ui.fadeToBlack(waitThenStartBattle)
end

local function _startIntro1()
    _ui.spawnDialogue('data/dialogue/cyclops/intro.json', false, nil)
end

function cyclops.init()
    _battle = game.control.encounter
    _ui = game.control.encounter.ui
    if _battle.shouldSkipIntro() then
        game.audio.playMusic('data/sounds/shower.json')
        _startPhase1()
    else
        game.audio.playMusic('data/sounds/water_stream_muted.json')
        _ui.setBackground('data/sprites/encounters/cyclops_intro.png')
        _ui.setSprite('data/sprites/dither/0.png')
        game.control.ui.fadeIn(_startIntro1)
    end
end

return cyclops
