local cutscene = {}

local _timer = 0.01
local _events
local _onComplete
local _index = 0
local _dialogueHandler = require('data/scripts/dialogue/dialogue_handler.lua')
local _cutscene

local _sprite1
local _sprite2
local _activeSprite
local _fader1 = dofile('data/scripts/ui/dither_fader.lua')
local _fader2 = dofile('data/scripts/ui/dither_fader.lua')
local _activeFader
local _previousVisual = nil

local function _fadeSprite(sprite)
    _activeFader.fadeTo(0, 0.5, nil)
    if _activeSprite == _sprite1 then
        _activeFader = _fader2
        _activeSprite = _sprite2
    else
        _activeFader = _fader1
        _activeSprite = _sprite1
    end
    game.object.setVisual(_activeSprite, sprite)
    _activeFader.fadeTo(100, 0.5, nil)
end

local _update

local function _sendComplete()
    if _onComplete ~= nil then
        _onComplete()
        _onComplete = nil
    end
end

local function _completeCutscene()
    game.events.unsubscribe('update', _update)
    _fadeSprite('data/sprites/dither/0.png')
    game.timer.queue(1.0, _sendComplete)
end

local function _tryLoadNextEvent()
    _index = _index + 1
    local nextEvent = _events[_index]
    if nextEvent == nil then
        _completeCutscene()
        return
    end
    if nextEvent.visual ~= nil and nextEvent.visual ~= _previousVisual then
        _fadeSprite(nextEvent.visual)
        _previousVisual = nextEvent.visual
    end
    local function completeTimer()
        _timer = nextEvent.duration or 0.01
    end
    if nextEvent.dialogue ~= nil then
        local dialogueBox = _cutscene.find('dialogueBox')
        _dialogueHandler.talk(dialogueBox, nextEvent.dialogue, completeTimer, false)
    else
        completeTimer()
    end
end

_update = function()
    if _timer <= 0 then
        return
    end
    local deltaTime = game.timer.getDeltaTime()
    _timer = _timer - deltaTime
    if _timer > 0 then
        return
    end
    _tryLoadNextEvent()
end

function cutscene.destroy()
    _dialogueHandler.close()
    game.events.unsubscribe('update', _update)
    _timer = -1
    if _cutscene ~= nil then
        _cutscene.destroy()
        _cutscene = nil
    end
end

function cutscene.instantiate(data, onComplete)
    _events = data
    _onComplete = onComplete
    _cutscene = game.object.instantiate('data/scenes/cutscene.json')
    local button = _cutscene.find('dialogueBox').getComponent('button')
    button.onClick.subscribe(_dialogueHandler.progress)

    _sprite1 = _cutscene.find('sprite1/sprite')
    _sprite2 = _cutscene.find('sprite2/sprite')
    _activeSprite = _sprite1
    _fader1.init(_cutscene.find('sprite1').getComponent('mask'), 0, true)
    _fader2.init(_cutscene.find('sprite2').getComponent('mask'), 0, true)
    _activeFader = _fader1

    game.events.subscribe('update', _update)
end

return cutscene
