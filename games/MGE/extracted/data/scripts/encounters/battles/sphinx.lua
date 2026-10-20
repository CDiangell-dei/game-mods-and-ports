local sphinx = {}

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
    _ui.setSprite('data/animations/sphinx/outro_win_2/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/sphinx/outro_win_2.json', false, _completeWin)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

function sphinx.losePumping2()
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
        game.timer.queueScaled(0.5, soundLoop)
    end
    soundLoop()
end

local function _enterLoseOutro2()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/sphinx/outro_loss_2/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/sphinx/outro_loss_2.json', false, nil)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _completeBattle2()
    _battle.stopBattle()
    local cumOutside = dofile('data/scripts/general/cum_outside.lua')
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
    cumOutside(onComplete)
end

local function _initPhase2()
    _timer.events = {}

    table.insert(_timer.events, {
        loops = 4,
        action = function()
            _ui.setBackground('data/sprites/dither/0.png')
            _ui.setSprite('data/animations/sphinx/2/data.json')
            _ui.setAnimatorSpeed(0.75)
            _ui.setLoopsPerPump(1)
        end,
    })
    table.insert(_timer.events, {
        loops = 10,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle2_1.json', true, nil) --why armpits
        end,
    })
    table.insert(_timer.events, {
        loops = 10,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle2_2.json', true, nil) --mindless beast
            _ui.setAnimatorSpeed(1.0)
        end,
    })
    table.insert(_timer.events, {
        loops = 10,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle2_3.json', true, nil) --even faster
            _ui.setAnimatorSpeed(1.1)
        end,
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle2_4.json', true, nil) --quick-shot
            _ui.setAnimatorSpeed(1.2)
        end,
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle2_5.json', true, nil) --hold a bit
            _ui.setAnimatorSpeed(1.25)
        end,
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle2_6.json', true, nil) --not yet
            _ui.setAnimatorSpeed(1.5)
        end,
    })
end

local function _startPhase2()
    local pumpCount = 70.0 * 1.5 --determined from events
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
    _ui.setSprite('data/animations/sphinx/outro_win_1/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/sphinx/outro_win_1.json', false, _preparePhase2)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

--PHASE 1

function sphinx.losePumping1()
    local _isUp = true
    local function soundLoop()
        if _loseComplete then
            return
        end
        _isUp = not _isUp
        if _isUp then
            game.audio.playSound('data/sounds/sex/rub2_up.json')
        else
            game.audio.playSound('data/sounds/sex/rub2_down.json')
        end
        game.timer.queueScaled(1.0, soundLoop)
    end
    soundLoop()
end

function sphinx.callBattleComplete()
    _loseComplete = true
    _battle.complete()
end

local function _enterLoseOutro1()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/sphinx/outro_loss_1/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/sphinx/outro_loss_1.json', false, nil)
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
    local cumOutside = dofile('data/scripts/general/cum_outside.lua')
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
    cumOutside(onComplete)
end

local function _initPhase1()
    table.insert(_timer.events, {
        loops = 4,
        action = function()
            _ui.setBackground('data/sprites/dither/0.png')
            _ui.setSprite('data/animations/sphinx/1/data.json')
            _ui.setAnimatorSpeed(0.75)
            _ui.setLoopsPerPump(1)
        end,
    })
    table.insert(_timer.events, {
        loops = 8,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle1_1.json', true, nil) --hard as rock
        end,
    })
    table.insert(_timer.events, {
        loops = 5,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle1_2.json', true, nil) --bit too much
        end,
    })
    table.insert(_timer.events, {
        loops = 4,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle1_3.json', true, nil) --lose any second
            _ui.setAnimatorSpeed(1.0)
        end,
    })
    table.insert(_timer.events, {
        loops = 4,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle1_4.json', true, nil) --uwah
        end,
    })
    table.insert(_timer.events, {
        loops = 8,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle1_5.json', true, nil) --hold it in
            _ui.setAnimatorSpeed(1.25)
        end,
    })
    table.insert(_timer.events, {
        loops = 12,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle1_6.json', true, nil) --blow any moment
        end,
    })
    table.insert(_timer.events, {
        loops = 1,
        action = function()
            _ui.spawnDialogue('data/dialogue/sphinx/battle1_7.json', true, nil) --cum
            game.audio.playSound('data/sounds/general/command_word.json')
        end,
    })
end

local function _startPhase1()
    local pumpCount = 46.0 * 1.25 --determined from events
    _battle.startBattle(pumpCount)
    _initPhase1()
    _timer.init()
    _timer.setOnComplete(_completeBattle1)
    game.control.ui.fadeIn(nil)
end

function sphinx.prepareBattle1()
    local function waitThenStartBattle()
        game.audio.playSound('data/sounds/general/start_battle.json')
        game.timer.queue(1.5, _startPhase1)
    end
    game.control.ui.fadeToBlack(waitThenStartBattle)
end

local function _startIntro1()
    _ui.spawnDialogue('data/dialogue/sphinx/intro.json', false, nil)
end

function sphinx.init()
    _battle = game.control.encounter
    _battle.isElite = true
    _ui = game.control.encounter.ui
    game.audio.playMusic('data/sounds/ambient1.json')
    if _battle.shouldSkipIntro() then
        _startPhase1()
    else
        _ui.setBackground('data/sprites/dither/0.png')
        _ui.setSprite('data/animations/sphinx/intro/0001.png')
        game.control.ui.fadeIn(_startIntro1)
    end
end

return sphinx
