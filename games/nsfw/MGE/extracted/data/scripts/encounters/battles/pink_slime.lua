local pinkSlime = {}

local _ui
local _battle
local _activePath = 1
local _timer = dofile('data/scripts/encounters/battles/battle_timer.lua')

local function _completeWin()
    local progress = _battle.exhaustion / _battle.requiredExhaustion
    local profit = progress * 10.0
    profit = math.floor(profit)
    _battle.complete(profit, nil)
end

local function _enterWinOutro()
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/pink_slime/outro_win/data.json')
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/pink_slime/outro_win.json', false, _completeWin)
    end
    local function fadeIn()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _enterLoseOutro()
    local isDown = false
    local isComplete = false
    local function soundLoop()
        if isComplete then
            return
        end
        if isDown then
            game.audio.playSound('data/sounds/sex/rub_down.json')
        else
            game.audio.playSound('data/sounds/sex/rub_up.json')
        end
        isDown = not isDown
        game.timer.queueScaled(1.0, soundLoop)
    end
    _ui.setBackground('data/sprites/dither/0.png')
    _ui.setSprite('data/animations/pink_slime/outro_loss/data.json')
    local function cumFinal()
        isComplete = true
        dofile('data/scripts/general/cum_outside.lua')
        game.timer.queue(3.0, _battle.complete)
    end
    local function startDialogue()
        _ui.spawnDialogue('data/dialogue/pink_slime/outro_loss.json', false, cumFinal)
    end
    local function fadeIn()
        soundLoop()
        game.control.ui.fadeIn(startDialogue)
    end
    game.timer.queue(1.0, fadeIn)
end

local function _completeBattle()
    _battle.stopBattle()
    local isFail = _battle.exhaustion < _battle.requiredExhaustion
    if isFail then
        local function completeLoss()
            if _battle.shouldSkipOutro(true) then
                _battle.complete()
            else
                game.control.ui.fadeToWhite(_enterLoseOutro)
            end
        end
        local cumOutside = dofile('data/scripts/general/cum_outside.lua')
        cumOutside(completeLoss)
    else
        local function completeWin()
            if _battle.shouldSkipOutro(false) then
                _completeWin()
            else
                game.control.ui.fadeToWhite(_enterWinOutro)
            end
        end
        local cumInside = dofile('data/scripts/general/cum_inside.lua')
        cumInside(completeWin)
    end
end

local function _startBattle()
    local pumpCount = 34.0 --determined from events
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
    game.audio.playSound('data/sounds/encounters/wet_tackle.json')
    game.control.ui.fadeToBlack(waitThenStartBattle)
end

local function _continueIntro()
    local function startTalking()
        if _activePath == 1 then
            _ui.spawnDialogue('data/dialogue/pink_slime/intro_2.json', false, _prepareBattle)
        else
            _ui.spawnDialogue('data/dialogue/pink_slime/intro_2b.json', false, _prepareBattle)
        end
    end
    _ui.fadeSprite('data/sprites/encounters/pink_slime_sprite.png')
    game.audio.playSound('data/sounds/encounters/slime_appear.json')
    game.timer.queue(1.5, startTalking)
end

local function _startIntro()
    _ui.spawnDialogue('data/dialogue/pink_slime/intro_1.json', false, _continueIntro)
end

function pinkSlime.init()
    _battle = game.control.encounter
    _ui = game.control.encounter.ui
    game.audio.playMusic('data/sounds/water_stream.json')
    if _battle.shouldSkipIntro() then
        _startBattle()
    else
        _ui.setBackground('data/sprites/encounters/pink_slime_intro.png')
        _ui.setSprite('data/sprites/dither/0.png')
        game.control.ui.fadeIn(_startIntro)
    end
end

function pinkSlime.setPath(path)
    _activePath = path
    if path == 1 then
        game.audio.playSound('data/sounds/encounters/drink_water.json')
    end
end

--Encounter Events
local function _paizuri()
    _ui.setSprite('data/animations/pink_slime/1/data.json')
    _ui.setLoopsPerPump(1)
end

local function _cowgirl()
    _ui.setSprite('data/animations/pink_slime/2/data.json')
    _ui.setLoopsPerPump(1)
end

local function _paizuriToCowgirl()
    _ui.setSprite('data/animations/pink_slime/1to2/data.json')
    _ui.setLoopsPerPump(math.huge)
end

local function _cowgirlToPaizuri()
    _ui.setSprite('data/animations/pink_slime/2to1/data.json')
    _ui.setLoopsPerPump(math.huge)
end

table.insert(_timer.events, {
    loops = 2,
    action = function()
        _ui.setBackground('data/sprites/encounters/pink_slime_bg.png')
        _ui.setAnimatorSpeed(0.75)
        _paizuri()
    end,
})
table.insert(_timer.events, {
    loops = 4,
    action = function()
        _ui.spawnDialogue('data/dialogue/pink_slime/battle_1.json', true, nil) --Prefer breasts?
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.spawnDialogue('data/dialogue/pink_slime/battle_2.json', true, nil) --Or butt.
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0)
        _paizuriToCowgirl()
    end,
})
table.insert(_timer.events, {
    loops = 6,
    action = function()
        _cowgirl()
    end,
})
table.insert(_timer.events, {
    loops = 2,
    action = function()
        _ui.spawnDialogue('data/dialogue/pink_slime/battle_3.json', true, nil) --Can change form.
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = _cowgirlToPaizuri,
})
table.insert(_timer.events, {
    loops = 4,
    action = function()
        _ui.setAnimatorSpeed(0.75)
        _paizuri()
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0)
        _paizuriToCowgirl()
    end,
})
--Slow 1
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.9)
        _cowgirl()
    end,
})
--Slow 2
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(0.8)
    end,
})
--Rather large.
table.insert(_timer.events, {
    loops = 6,
    action = function()
        _ui.spawnDialogue('data/dialogue/pink_slime/battle_4.json', true, nil)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0)
        _cowgirlToPaizuri()
    end,
})
--Stamina match?
table.insert(_timer.events, {
    loops = 4,
    action = function()
        _ui.spawnDialogue('data/dialogue/pink_slime/battle_5.json', true, nil)
        _ui.setAnimatorSpeed(0.75)
        _paizuri()
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.0)
        _paizuriToCowgirl()
    end,
})
--Ramp up
table.insert(_timer.events, {
    loops = 1,
    action = _cowgirl,
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
    loops = 2,
    action = function()
        _ui.setAnimatorSpeed(2.0)
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.5)
        _cowgirlToPaizuri()
    end,
})
table.insert(_timer.events, {
    loops = 6,
    action = function()
        _ui.setAnimatorSpeed(1.0)
        _paizuri()
    end,
})
table.insert(_timer.events, {
    loops = 1,
    action = function()
        _ui.setAnimatorSpeed(1.5)
        _paizuriToCowgirl()
    end,
})
table.insert(_timer.events, {
    loops = 6,
    action = function()
        _ui.setAnimatorSpeed(2.0)
        _cowgirl()
    end,
})

return pinkSlime
