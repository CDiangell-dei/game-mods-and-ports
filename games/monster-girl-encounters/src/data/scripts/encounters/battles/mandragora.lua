local mandragora = {}

local _ui
local _battle
local _timer = dofile('data/scripts/encounters/battles/battle_timer.lua')
local _loseComplete = false

local function _completeWin()
    local progress = _battle.exhaustion / _battle.requiredExhaustion
    local profit = progress * 10.0
    profit = math.floor(profit)
    _battle.complete(profit, nil)
end

local function _enterWinOutro()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/mandragora/outro_win/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/mandragora/outro_win.json', false, _completeWin)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _enterLoseOutro()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/mandragora/outro_loss/data.json')
    local function complete()
        _loseComplete = true
        _battle.complete()
    end
    local function cumThree()
        local function spawnDialogue()
            _ui.spawnDialogue('data/dialogue/mandragora/outro_loss_4.json', false, complete)
        end
        game.timer.queue(2.2, spawnDialogue)
    end
    local function cumTwo()
        local function spawnDialogue()
            _ui.spawnDialogue('data/dialogue/mandragora/outro_loss_3.json', false, cumThree)
        end
        game.timer.queue(2.2, spawnDialogue)
    end
    local function cumOne()
        local function spawnDialogue()
            _ui.spawnDialogue('data/dialogue/mandragora/outro_loss_2.json', false, cumTwo)
        end
        game.timer.queue(2.2, spawnDialogue)
    end
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/mandragora/outro_loss_1.json', false, cumOne)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _completeBattle()
    _battle.stopBattle()
    local cumInside = dofile('data/scripts/general/cum_inside.lua')
    local isFail = _battle.exhaustion < _battle.requiredExhaustion
    local onComplete
    if isFail then
        onComplete = function()
            if _battle.shouldSkipOutro(true) then
                _battle.complete()
            else
                game.control.ui.fadeToWhite(_enterLoseOutro)
            end
        end
    else
        onComplete = function()
            if _battle.shouldSkipOutro(false) then
                _completeWin()
            else
                game.control.ui.fadeToWhite(_enterWinOutro)
            end
        end
    end
    cumInside(onComplete)
end

local function _startBattle()
    local pumpCount = 75.0 --determined from events
    _battle.startBattle(pumpCount)
    _timer.init()
    _timer.setOnComplete(_completeBattle)
    game.control.ui.fadeIn(nil)
end

local function _prepareBattle()
    local function waitThenStartBattle()
        game.audio.playSound('data/sounds/general/start_battle.json')
        game.timer.queue(1.5, _startBattle)
    end
    game.control.ui.fadeToBlack(waitThenStartBattle)
end

local function _startIntro()
    _ui.spawnDialogue('data/dialogue/mandragora/intro.json', false, _prepareBattle)
end

function mandragora.init()
    _battle = game.control.encounter
    _ui = game.control.encounter.ui
    game.audio.playMusic('data/sounds/forest.json')
    if _battle.shouldSkipIntro() then
        _startBattle()
    else
        _ui.setBackground('data/sprites/encounters/mandragora_intro.png')
        _ui.setSprite('data/sprites/black.png')
        game.control.ui.fadeIn(_startIntro)
    end
end

function mandragora.setPath(_)
    local _isUp = true
    local function soundLoop()
        if _loseComplete then
            return
        end
        _isUp = not _isUp
        if _isUp then
            game.audio.playSound('data/sounds/sex/onahole_up.json')
        else
            game.audio.playSound('data/sounds/sex/onahole_down.json')
        end
        game.timer.queueScaled(0.5, soundLoop)
    end
    soundLoop()
end

--Encounter Events
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setBackground('data/sprites/dither/0.png')
        _ui.setSprite('data/animations/mandragora/1/data.json')
        _ui.setAnimatorSpeed(0.75)
        _ui.setLoopsPerPump(1)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.spawnDialogue('data/dialogue/mandragora/battle_1.json', true, nil) --engulf penis
        _ui.setAnimatorSpeed(0.8125)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.875)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.9375)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0625)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.125)
        _ui.setSprite('data/animations/mandragora/2/data.json')
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.1875)
        _ui.setSprite('data/animations/mandragora/1/data.json')
    end,
})
table.insert(_timer.events, {
    loops = 4,
    action = function()
        _ui.spawnDialogue('data/dialogue/mandragora/battle_2.json', true, nil) --need nector
        _ui.setAnimatorSpeed(1.25)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.75)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.8125)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.875)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.9375)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.spawnDialogue('data/dialogue/mandragora/battle_3.json', true, nil) --stamen massage
        _ui.setAnimatorSpeed(1.0)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0625)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.125)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.1875)
    end,
})
table.insert(_timer.events, {
    loops = 4,
    action = function()
        _ui.setAnimatorSpeed(1.25)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.75)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.spawnDialogue('data/dialogue/mandragora/battle_4.json', true, nil) --delicious
        _ui.setAnimatorSpeed(0.5)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.625)
        _ui.setSprite('data/animations/mandragora/2/data.json')
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.75)
        _ui.setSprite('data/animations/mandragora/1/data.json')
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.875)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.125)
    end,
})
table.insert(_timer.events, {
    loops = 4,
    action = function()
        _ui.spawnDialogue('data/dialogue/mandragora/battle_5.json', true, nil) --hand's speed increases
        _ui.setAnimatorSpeed(1.25)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.3125)
        _ui.setSprite('data/animations/mandragora/2/data.json')
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.375)
        _ui.setSprite('data/animations/mandragora/1/data.json')
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.4375)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.5)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.5625)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.625)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.6875)
    end,
})
table.insert(_timer.events, {
    loops = 8,
    action = function()
        _ui.spawnDialogue('data/dialogue/mandragora/battle_6.json', true, nil) --cum
        _ui.setAnimatorSpeed(1.75)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0)
        _ui.setSprite('data/animations/mandragora/3/data.json')
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0)
        _ui.setSprite('data/animations/mandragora/4/data.json')
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.25)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.5)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.75)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(2.0)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(2.2)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(2.3)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(2.4)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(2.5)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(2.6)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(2.7)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(2.8)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(2.9)
    end,
})
table.insert(_timer.events, {
    loops = 10,
    action = function()
        _ui.setAnimatorSpeed(3.0)
    end,
})

return mandragora
