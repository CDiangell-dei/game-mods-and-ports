local imps = {}

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
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/imps/win/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/imps/win.json', false, _completeWin)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

--PHASE 1

function imps.losePumping1()
    local function soundLoop()
        if _loseComplete then
            return
        end
        game.audio.playSound('data/sounds/sex/slurp_soft.json')
        local timer = (math.random() * 3.0) + 2.0
        game.timer.queueScaled(timer, soundLoop)
    end
    soundLoop()
end

function imps.callBattleComplete()
    _loseComplete = true
    _battle.complete()
end

local function _enterLoseOutro1()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/imps/loss_1/data.json')
    local function startDialogue()
        imps.losePumping1()
        _ui.spawnDialogue('data/dialogue/imps/loss_1.json', false, nil)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _completeBattle1()
    _battle.stopBattle()
    local cum = dofile('data/scripts/general/cum_inside.lua')
    local isFail = _battle.exhaustion < _battle.requiredExhaustion
    local onComplete
    if isFail then
        onComplete = function()
            if _battle.shouldSkipOutro(true) then
                imps.callBattleComplete()
            else
                game.control.ui.fadeToWhite(_enterLoseOutro1)
            end
        end
    else
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

local animationCounter = 0

local function _updateBattleAnimation()
    animationCounter = animationCounter + 1
    if animationCounter > 5 then
        animationCounter = 1
    end
    if animationCounter == 1 then
        _ui.setSprite('data/animations/imps/1/data.json')
    elseif animationCounter == 2 then
        _ui.setSprite('data/animations/imps/2/data.json')
    elseif animationCounter == 3 then
        _ui.setSprite('data/animations/imps/3/data.json')
    elseif animationCounter == 4 then
        _ui.setSprite('data/animations/imps/4/data.json')
    else
        _ui.setSprite('data/animations/imps/5/data.json')
    end
end

local function _initPhase1()
    for _=1, 96 do
        table.insert(_timer.events, {
            loops = 1,
            action = function()
                _updateBattleAnimation()
            end,
        })
    end
    _timer.events[1].action = function()
        _ui.setBackground('data/sprites/dither/0.png')
        _ui.setLoopsPerPump(1.0)
        _ui.setAnimatorSpeed(1.0)
        _updateBattleAnimation()
    end
    _timer.events[5].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_1.json', true, nil)
        _updateBattleAnimation()
    end
    _timer.events[13].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_2.json', true, nil)
        _updateBattleAnimation()
    end
    _timer.events[21].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_3.json', true, nil)
        _updateBattleAnimation()
    end
    _timer.events[27].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_4.json', true, nil)
        _updateBattleAnimation()
    end
    _timer.events[35].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_5.json', true, nil)
        _updateBattleAnimation()
    end
    _timer.events[43].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_6.json', true, nil)
        _updateBattleAnimation()
    end
    _timer.events[51].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_7.json', true, nil)
        _updateBattleAnimation()
    end
    _timer.events[57].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_8.json', true, nil)
        _updateBattleAnimation()
    end
    _timer.events[65].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_9.json', true, nil)
        _ui.setAnimatorSpeed(1.25)
        _updateBattleAnimation()
    end
    _timer.events[73].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_10.json', true, nil)
        _ui.setAnimatorSpeed(1.5)
        _updateBattleAnimation()
    end
    _timer.events[85].action = function()
        _ui.spawnDialogue('data/dialogue/imps/battle_11.json', true, nil)
        _updateBattleAnimation()
    end
end

local function _startPhase1()
    local pumpCount = 96.0 --determined from events
    _battle.startBattle(pumpCount)
    _initPhase1()
    _timer.init()
    _timer.setOnComplete(_completeBattle1)
    game.control.ui.fadeIn(nil)
end

function imps.prepareBattle1()
    --[[
    local function waitThenStartBattle()
        game.audio.playSound('data/sounds/general/start_battle.json')
        game.timer.queue(1.5, _startPhase1)
    end
    game.control.ui.fadeToBlack(waitThenStartBattle)
    ]]--
    game.timer.queue(1.5, _startPhase1)
end

local function _startIntro1()
    _ui.spawnDialogue('data/dialogue/imps/intro_1.json', false, nil)
end

function imps.init()
    _battle = game.control.encounter
    _ui = game.control.encounter.ui
    game.audio.playMusic('data/sounds/ambient1.json')
    if _battle.shouldSkipIntro() then
        _startPhase1()
    else
        _ui.setBackground('data/sprites/dither/0.png')
        _ui.setSprite('data/sprites/encounters/imps_intro_1.png')
        game.control.ui.fadeIn(_startIntro1)
    end
end

return imps
