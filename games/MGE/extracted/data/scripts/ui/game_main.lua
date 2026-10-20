local mainUI = {}

local _fader = dofile('data/scripts/ui/encounter_fader.lua')
local _dialogueHandler = require('data/scripts/dialogue/dialogue_handler.lua')
local _sliderSmoother = dofile('data/scripts/ui/slider_smoother.lua')
local _tiles = dofile('data/scripts/ui/main_tiles.lua')
local _buffs = dofile('data/scripts/ui/main_buffs.lua')
local _map = dofile('data/scripts/ui/map.lua')
local _mods = require('mods/mod_manager.lua') -- MOD
local _object
local _goldObject
local _eppObject
local _gold = 0
local _goldGoal = 0
local _exhaustionPerPump = 0
local _exhaustionPerPumpGoal = 0
local _progress1
local _progress2
local _timer
local _pumpTimer

local function _openMenu()
    dofile('data/scripts/ui/menu.lua')
end

local function _updateLaggingNumber(object, goal, current, extraStartText, extraEndText, formatting)
    if goal == current then
        return current
    end
    local difference = math.abs(goal - current)
    local increment = math.floor(difference / 30)
    increment = math.max(increment, 1)
    -- MOD: very large numbers would take minutes to count up; mods can speed that up
    increment = _mods.filter('laggingIncrement', increment, difference, current)
    if goal < current then
        current = current - increment
    else
        current = current + increment
    end
    local value = string.format(formatting, current)
    if extraStartText then
        value = extraStartText .. value
    end
    if extraEndText then
        value = value .. extraEndText
    end
    object.find('shadow').getComponent('text').setText(value)
    object.find('text').getComponent('text').setText(value)
    return current
end

function mainUI.instantiate(onComplete)
    _object = game.object.instantiate('data/scenes/main.json')
    _tiles.init()
    _goldObject = _object.find('coin')
    _eppObject = _object.find('inventoryHolder/inventory/header/epp')
    _progress1 = _object.find('progress1').getComponent('slider')
    _progress2 = _object.find('progress2').getComponent('slider')
    _timer = _object.find('timer').getComponent('slider')
    _pumpTimer = _object.find('pumpTimer').getComponent('slider')

    local simpleTooltip = nil
    local function displayEppTooltip()
        if simpleTooltip ~= nil then
            simpleTooltip.destroy()
        end
        simpleTooltip = dofile('data/scripts/ui/tooltip_simple.lua')
        simpleTooltip.init('epp_description')
    end
    local function destroyEppTooltip()
        if simpleTooltip ~= nil then
            simpleTooltip.destroy()
            simpleTooltip = nil
        end
    end
    local eppButton = _eppObject.getComponent('button')
    eppButton.onMouseEnter.subscribe(displayEppTooltip)
    eppButton.onMouseExit.subscribe(destroyEppTooltip)

    local menuButton = dofile('data/scripts/ui/default_button.lua')
    local menuButtonObject = _object.find('menuButton')
    menuButton.init(menuButtonObject)
    menuButtonObject.find('button').getComponent('button').onClick.subscribe(_openMenu)

    _mods.call('onMainUiReady', _object) -- MOD: skip_battle adds its toggle here

    for _=1, game.control.lives do
        mainUI.gainLife()
    end
    _fader.init(_object.find('viewportCover'), false, onComplete)
    local dither = dofile('data/scripts/ui/dither_fader.lua')
    dither.init(_object.find('inventoryHolder').getComponent('mask'), 0, false)
    local function fade()
        dither.fadeTo(100, 0.5, nil)
    end
    game.timer.queue(2.25, fade)
    game.audio.playMusic('data/sounds/cave.json')
end

function mainUI.destroy()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
    _tiles.destroy()
    mainUI.closeDialogue()
    mainUI.cancelFade()
end

function mainUI.update(deltaTime)
    _tiles.update(deltaTime)
    _sliderSmoother.update(deltaTime)
    _gold = _updateLaggingNumber(_goldObject, _goldGoal, _gold, nil, ' G', '%.5g')
    _exhaustionPerPump = _updateLaggingNumber(_eppObject,
        _exhaustionPerPumpGoal, _exhaustionPerPump, 'EPP: ', nil, '%.10g')
end

function mainUI.prepareEncounter(encounterTree)
    local function spawnSelection()
        _map.openMap(encounterTree)
    end
    _fader.prepareEncounterSelection(spawnSelection)
end

mainUI.enterEncounter = _fader.transitionToEncounter

function mainUI.displayGold(amount)
    amount = _mods.filter('sanitizeNumber', amount, 'display') -- MOD
    _goldGoal = math.floor(amount)
end

function mainUI.displayExhaustionPerPump(amount)
    amount = _mods.filter('sanitizeNumber', amount, 'display') -- MOD
    _exhaustionPerPumpGoal = math.floor(amount)
end

mainUI.addBuff = _buffs.add

mainUI.removeBuff = _buffs.remove

mainUI.updateTile = _tiles.updateTile

mainUI.highlightTile = _tiles.highlightTile

mainUI.spawnTileOrb = _tiles.spawnTileOrb

mainUI.unhighlightTile = _tiles.unhighlightTile

mainUI.triggerTile = _tiles.triggerHighlightTile

mainUI.refreshTiles = _tiles.refreshTiles

mainUI.indicatePossibleCombinations = _tiles.indicatePossibleCombinations

mainUI.refreshPossibleCombinations = _tiles.refreshPossibleCombinations

mainUI.combineTiles = _tiles.combineTiles

mainUI.setTrashReceiver = _tiles.setTrashReceiver
mainUI.setTileInputLocked = _tiles.setInputLocked

function mainUI.setInventorySize(current, capacity)
    local currentString = tostring(current)
    local capacityString = tostring(capacity)
    local currentShadow = _object.find('inventoryHolder/inventory/header/current/shadow').getComponent('text')
    local currentText = _object.find('inventoryHolder/inventory/header/current/text').getComponent('text')
    currentShadow.setText(currentString)
    currentText.setText(currentString)

    local capacityShadow = _object.find('inventoryHolder/inventory/header/limit/shadow').getComponent('text')
    local capacityText = _object.find('inventoryHolder/inventory/header/limit/text').getComponent('text')
    capacityShadow.setText(capacityString)
    capacityText.setText(capacityString)
end

function mainUI.setProgress(amount)
    _sliderSmoother.set(_progress1, amount)
    _sliderSmoother.set(_progress2, amount)
end

function mainUI.setTimer(amount)
    _sliderSmoother.set(_timer, amount)
end

function mainUI.setPump(amount)
    _sliderSmoother.set(_pumpTimer, amount, 10.0)
end

function mainUI.fadeToBlack(onComplete, timerOverride)
    local time = timerOverride or 0.5
    _fader.fadeOut(time, onComplete, 0.07058824, 0.07450981, 0.1098039)
end

function mainUI.fadeToWhite(onComplete, timerOverride)
    local time = timerOverride or 0.5
    --_fader.fadeOut(time, onComplete, 0.6456033, 0.6456033, 0.735849)
    _fader.fadeOut(time, onComplete, 1.0, 1.0, 1.0)
end

function mainUI.fadeToTransition(onComplete)
    game.audio.playMusic('data/sounds/cave.json')
    _fader.fadeToTransition(0.5, onComplete)
end

function mainUI.fadeIn(onComplete, timerOverride)
    local time = timerOverride or 0.5
    _fader.fadeIn(time, onComplete)
end

mainUI.cancelFade = _fader.cancel

function mainUI.spawnDialogue(dialogue, onComplete, autoProgress)
    _dialogueHandler.talk(_object.find('dialogueBox'), dialogue, onComplete, autoProgress)
end

mainUI.progressDialogue = _dialogueHandler.progress

mainUI.closeDialogue = _dialogueHandler.close

function mainUI.loseLife(onComplete)
    local loseHandler = dofile('data/scripts/ui/lose_handler.lua')
    loseHandler.init(onComplete)
end

function mainUI.loseLifeFast()
    local object = game.object.getRoot().find('main')
    local count = object.find('hearts').getChildCount()
    local heart = object.find('hearts').getChild(count)
    heart.destroy()
end

function mainUI.gainLife()
    local parent = _object.find('hearts')
    local count = parent.getChildCount()
    local heart = game.object.instantiate('data/scenes/main_heart.json', parent)
    local speed = 0.9 + ((count % 3) * 0.1)

    heart.find('sprite').getComponent('animator').setSpeed(speed)
end

function mainUI.setLevel(amount)
    local shadow = _object.find('level/shadow').getComponent('text')
    local text = _object.find('level/text').getComponent('text')
    local s = 'LV ' .. tostring(amount)
    shadow.setText(s)
    text.setText(s)
end

return mainUI
