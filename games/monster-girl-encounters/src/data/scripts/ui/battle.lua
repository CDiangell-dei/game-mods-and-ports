local _mods = require('mods/mod_manager.lua') -- MOD
local battleUI = {}

local _pumper = dofile('data/scripts/ui/battle_pumper.lua')
local _goalVisual = dofile('data/scripts/ui/battle_goal_visual.lua')
local _rewarder = nil
local _isComplete = false
local _object
local _sprite1
local _sprite2
local _activeSprite
local _fader1 = dofile('data/scripts/ui/dither_fader.lua')
local _fader2 = dofile('data/scripts/ui/dither_fader.lua')
local _activeFader
local _eventReceiver = dofile('data/scripts/event_receiver.lua')
local _loopCount = 0
local _requiredLoops = 9999

local function _tryPump()
    if _isComplete then
        return
    end
    _loopCount = _loopCount + 1
    if _loopCount < _requiredLoops then
        return
    end
    _loopCount = 0
    local exhaustionData = {
        exhaustion = 0,
        pumpers = {},
    }
    game.control.trigger('pump', exhaustionData)
end

local function _onAnimator1Complete()
    if _activeSprite ~= _sprite1 then
        return
    end
    _tryPump()
    _eventReceiver.invoke()
end

local function _onAnimator2Complete()
    if _activeSprite ~= _sprite2 then
        return
    end
    _tryPump()
    _eventReceiver.invoke()
end

function battleUI.instantiate()
    local parent = game.object.getRoot().find('main/viewport')
    _object = game.object.instantiate('data/scenes/encounters/battle.json', parent)
    _sprite1 = _object.find('sprite1/sprite')
    _sprite2 = _object.find('sprite2/sprite')
    _activeSprite = _sprite1
    _fader1.init(_object.find('sprite1').getComponent('mask'), 0, false)
    _fader2.init(_object.find('sprite2').getComponent('mask'), 0, false)
    _activeFader = _fader1
    _sprite1.getComponent('animator').onCompletion.subscribe(_onAnimator1Complete)
    _sprite2.getComponent('animator').onCompletion.subscribe(_onAnimator2Complete)
end

function battleUI.destroy()
    if _object == nil then
        return
    end
    _object.destroy()
    _object = nil
    _goalVisual.destroy()
end

function battleUI.update(deltaTime)
    if not _isComplete then
        _pumper.update(deltaTime)
        local required = game.control.encounter.requiredExhaustion
        if required > 0 then
            local progress = game.control.encounter.exhaustion / required
            progress = _mods.filter('sanitizeNumber', progress, 'progress') -- MOD
            game.control.ui.setProgress(progress)
            _goalVisual.updateProgress(progress)
        end
    end
    if _rewarder ~= nil then
        _rewarder.update(deltaTime)
    end
end

function battleUI.setBackground(background)
    local obj = _object.find('background')
    obj.setSize(410, 410)
    obj.setPosition(0, 0)
    if background == nil then
        obj.getComponent('image').setColor(0, 0, 0, 0)
    else
        obj.getComponent('image').setColor(1.0, 1.0, 1.0, 1.0)
        game.object.setVisual(obj, background)
    end
end

function battleUI.setSprite(sprite)
    _fader2.fadeTo(0, 0, nil)
    _fader1.fadeTo(100, 0, nil)
    local obj = _object.find('sprite1/sprite')
    game.object.setVisual(obj, sprite)
    _activeSprite = _sprite1
    _activeFader = _fader1
end

function battleUI.fadeSprite(sprite, fadeTime)
    fadeTime = fadeTime or 0.5
    _activeFader.fadeTo(0, fadeTime, nil)
    if _activeSprite == _sprite1 then
        _activeFader = _fader2
        _activeSprite = _sprite2
    else
        _activeFader = _fader1
        _activeSprite = _sprite1
    end
    game.object.setVisual(_activeSprite, sprite)
    _activeFader.fadeTo(100, fadeTime, nil)
end

function battleUI.subscribeOnAnimationComplete(callback)
    _eventReceiver.subscribe(callback)
end

function battleUI.unsubscribeOnAnimationComplete(callback)
    _eventReceiver.unsubscribe(callback)
end

function battleUI.setLoopsPerPump(loopCount)
    _requiredLoops = loopCount or 1
    _loopCount = 0
end

function battleUI.getSimulatedPumpCount(duration)
    local animator = _activeSprite.getComponent('animator')
    local loopDuration = animator.getLoopDuration()
    if loopDuration <= 0 then
        return 0
    end
    return math.floor(duration / loopDuration / _requiredLoops)
end

function battleUI.setAnimatorSpeed(speed)
    _sprite1.getComponent('animator').setSpeed(speed)
    _sprite2.getComponent('animator').setSpeed(speed)
end

function battleUI.spawnDialogue(dialogue, isAuto, onComplete)
    local boxButton = nil
    local function progress()
        game.control.ui.progressDialogue()
    end
    local function completeDialogue()
        if boxButton ~= nil then
            boxButton.onClick.unsubscribe(progress)
        end
        if onComplete ~= nil then
            onComplete()
        end
    end
    if not isAuto then
        boxButton = game.object.getRoot().find('main/dialogueBox').getComponent('button')
        boxButton.onClick.subscribe(progress)
    end
    game.control.ui.spawnDialogue(dialogue, completeDialogue, isAuto)
end

function battleUI.stopBattle()
    _isComplete = true
    _pumper.refresh()
    game.control.ui.setProgress(0)
    _goalVisual.stop()
end

function battleUI.resumeBattle()
    _isComplete = false
end

function battleUI.pump(exhaustionData)
    _pumper.pump(exhaustionData.pumpers)
    game.control.ui.displayExhaustionPerPump(exhaustionData.exhaustion)
    game.control.trigger('eppUpdate', exhaustionData.exhaustion)
end

function battleUI.gainReward(amount, onComplete, item)
    _rewarder = dofile('data/scripts/ui/battle_rewarder.lua')
    _rewarder.instantiate(amount, item, onComplete)
end

return battleUI
