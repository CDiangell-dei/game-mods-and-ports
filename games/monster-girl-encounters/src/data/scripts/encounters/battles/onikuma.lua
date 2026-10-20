local onikuma = {}

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
    _ui.setBackground('data/sprites/encounters/onikuma_bg.png')
    _ui.setSprite('data/animations/onikuma/outro_win/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/onikuma/outro_win.json', false, _completeWin)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _enterLoseOutro()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/onikuma/outro_loss_1/data.json')
    local function cumFinal()
        _loseComplete = true
        dofile('data/scripts/general/cum_inside.lua')
        game.timer.queue(3.0, _battle.complete)
    end
    local function playSecondDialogue()
        local function spawnDialogue()
            _ui.spawnDialogue('data/dialogue/onikuma/outro_loss_2.json', false, cumFinal)
        end
        local function setSprite()
            _ui.setSprite('data/animations/onikuma/outro_loss_2/data.json')
            game.timer.queue(2.0, spawnDialogue)
        end
        game.timer.queue(0.2, setSprite)
    end
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/onikuma/outro_loss_1.json', false, playSecondDialogue)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _completeBattle()
    _battle.stopBattle()
    local cumOutside = dofile('data/scripts/general/cum_outside.lua')
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
    cumOutside(onComplete)
end

local function _startBattle()
    local pumpCount = 80.0 --determined from events
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
    _ui.spawnDialogue('data/dialogue/onikuma/intro.json', false, _prepareBattle)
end

function onikuma.init()
    _battle = game.control.encounter
    _ui = game.control.encounter.ui
    game.audio.playMusic('data/sounds/forest.json')
    if _battle.shouldSkipIntro() then
        _startBattle()
    else
        _ui.setBackground('data/sprites/encounters/onikuma_intro.png')
        _ui.setSprite('data/sprites/dither/0.png')
        game.control.ui.fadeIn(_startIntro)
    end
end

function onikuma.setPath(_)
    local function soundLoop()
        if _loseComplete then
            return
        end
        game.audio.playSound('data/sounds/sex/medium_plap.json')
        game.timer.queueScaled(1.0, soundLoop)
    end
    soundLoop()
end

--Encounter Events
table.insert(_timer.events, {
    loops = 4,
    action = function()
        _ui.setBackground('data/sprites/encounters/onikuma_bg.png')
        _ui.setSprite('data/animations/onikuma/1/data.json')
        _ui.setAnimatorSpeed(0.75)
        _ui.setLoopsPerPump(1)
    end,
})
table.insert(_timer.events, {
    loops = 4,
    action = function()
        _ui.spawnDialogue('data/dialogue/onikuma/battle_1.json', true, nil) --go a little faster
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0)
    end,
})
table.insert(_timer.events, {
    loops = 6,
    action = function()
        _ui.spawnDialogue('data/dialogue/onikuma/battle_2.json', true, nil) --plunging deep
    end,
})
table.insert(_timer.events, {
    loops = 16,
    action = function()
        _ui.spawnDialogue('data/dialogue/onikuma/battle_3.json', true, nil) --smell pheremones + follow up
    end,
})
table.insert(_timer.events, {
    loops = 8,
    action = function()
        _ui.spawnDialogue('data/dialogue/onikuma/battle_4.json', true, nil) --made to be bred
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.5)
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
        _ui.setAnimatorSpeed(1.0)
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
        _ui.setSprite('data/animations/onikuma/2/data.json')
    end,
})
table.insert(_timer.events, {
    loops = 12,
    action = function()
        _ui.spawnDialogue('data/dialogue/onikuma/battle_5.json', true, nil) --going even faster?
    end,
})
table.insert(_timer.events, {
    loops = 8,
    action = function()
        _ui.spawnDialogue('data/dialogue/onikuma/battle_6.json', true, nil) --breeding bitch
    end,
})
table.insert(_timer.events, {
    loops = 12,
    action = function()
        _ui.setAnimatorSpeed(2.0)
    end,
})
table.insert(_timer.events, {
    loops = 4,
    action = function()
        _ui.spawnDialogue('data/dialogue/onikuma/battle_7.json', true, nil) --cumming
    end,
})

return onikuma
