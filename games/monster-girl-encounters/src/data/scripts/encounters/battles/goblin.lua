local goblin = {}

local _ui
local _battle
local _timer = dofile('data/scripts/encounters/battles/battle_timer.lua')
local _profit = 0
local _loseComplete = false

--PHASE 2

local function _gainBuff(key)
    local data = require('data/scripts/data.lua')
    local buff = data.buffs[key]
    game.control.buffs.add(buff)
end

local function _completeWin()
    local progress = _battle.exhaustion / _battle.requiredExhaustion
    local profit = progress * 10.0
    profit = math.floor(profit) + _profit
    _gainBuff('well_rested')
    _battle.complete(profit, nil)
end

local function _winOutro()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/goblin/outro_win/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/goblin/outro_win.json', false, _completeWin)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

--PHASE 1

function goblin.losePumping1()
    local isUp = true
    local counter = 0
    local function soundLoop()
        isUp = not isUp
        counter = counter + 1
        if _loseComplete then
            return
        end
        if counter > 7 then
            counter = 0
            game.audio.playSound('data/sounds/sex/slurp_soft.json')
        end
        if isUp then
            game.audio.playSound('data/sounds/sex/rub_up.json')
        else
            game.audio.playSound('data/sounds/sex/rub_down.json')
        end
        game.timer.queueScaled(1.0, soundLoop)
    end
    soundLoop()
end

function goblin.callBattleComplete()
    _loseComplete = true
    _gainBuff('tired')
    local gold = game.control.getGold()
    if gold > 0 then
        local cost = math.min(gold, 3)
        game.control.loseGold(cost)
    end
    _battle.complete()
end

local function _enterLoseOutro1()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/goblin/outro_loss/data.json')
    local function startDialogue()
        goblin.losePumping1()
        _ui.spawnDialogue('data/dialogue/goblin/outro_loss.json', false, nil)
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
                goblin.callBattleComplete()
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

local function _initPhase1()
    table.insert(_timer.events, {
        loops = 4,
        action = function()
            _ui.setBackground('data/sprites/dither/0.png')
            _ui.setSprite('data/animations/goblin/1/data.json')
            _ui.setLoopsPerPump(1.0)
            _ui.setAnimatorSpeed(0.75)
        end
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/goblin/battle1.json', true, nil)
            _ui.setAnimatorSpeed(0.9)
        end
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/goblin/battle2.json', true, nil)
            _ui.setAnimatorSpeed(1.0)
        end
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/goblin/battle3.json', true, nil)
            _ui.setAnimatorSpeed(1.25)
        end
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/goblin/battle4.json', true, nil)
        end
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/goblin/battle5.json', true, nil)
        end
    })
    table.insert(_timer.events, {
        loops = 16,
        action = function()
            _ui.spawnDialogue('data/dialogue/goblin/battle6.json', true, nil)
            _ui.setAnimatorSpeed(1.5)
        end
    })
end

local function _startPhase1()
    local pumpCount = 80.0 --determined from events
    _battle.startBattle(pumpCount)
    _initPhase1()
    _timer.init()
    _timer.setOnComplete(_completeBattle1)
    game.control.ui.fadeIn(nil)
end

function goblin.prepareBattle1()
    local function waitThenStartBattle()
        game.audio.playSound('data/sounds/general/start_battle.json')
        game.timer.queue(1.5, _startPhase1)
    end
    game.control.ui.fadeToBlack(waitThenStartBattle)
end

local function _startIntro1()
    _ui.spawnDialogue('data/dialogue/goblin/intro_1.json', false, nil)
end

function goblin.init()
    _battle = game.control.encounter
    _ui = game.control.encounter.ui
    game.audio.playMusic('data/sounds/ambient1.json')
    if _battle.shouldSkipIntro() then
        _startPhase1()
    else
        _ui.setBackground('data/sprites/encounters/goblin_intro_bg.png')
        _ui.setSprite('data/sprites/encounters/goblin_intro_1.png')
        game.control.ui.fadeIn(_startIntro1)
    end
end

return goblin
