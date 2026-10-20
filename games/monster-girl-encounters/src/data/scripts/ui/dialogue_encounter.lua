local dialogueEncounter = {}

local _object
local _sprite1
local _sprite2
local _activeSprite
local _fader1 = dofile('data/scripts/ui/dither_fader.lua')
local _fader2 = dofile('data/scripts/ui/dither_fader.lua')
local _activeFader

function dialogueEncounter.init(onComplete)
    local parent = game.object.getRoot().find('main/viewport')
    _object = game.object.instantiate('data/scenes/encounters/random.json', parent)
    _sprite1 = _object.find('sprite1/sprite')
    _sprite2 = _object.find('sprite2/sprite')
    _activeSprite = _sprite1
    _fader1.init(_object.find('sprite1').getComponent('mask'), 0, false)
    _fader2.init(_object.find('sprite2').getComponent('mask'), 0, false)
    _activeFader = _fader1
    game.control.ui.fadeIn(onComplete)
end

function dialogueEncounter.setBackground(background)
    game.object.setVisual(_object, background)
end

function dialogueEncounter.setSprite(sprite)
    _fader2.fadeTo(0, 0, nil)
    _fader1.fadeTo(100, 0, nil)
    local obj = _object.find('sprite1/sprite')
    game.object.setVisual(obj, sprite)
    _activeSprite = _sprite1
    _activeFader = _fader1
end

function dialogueEncounter.fadeSprite(sprite)
    local fadeTime = 0.5
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

function dialogueEncounter.completeEncounter()
    game.control.ui.fadeToTransition(game.control.completeEncounter)
end

function dialogueEncounter.spawnDialogue(dialogue, onComplete)
    local function completeDialogue()
        game.object.getRoot().find('main/dialogueBox').getComponent('button').
            onClick.unsubscribe(game.control.ui.progressDialogue)
        onComplete()
    end
    game.object.getRoot().find('main/dialogueBox').getComponent('button').
        onClick.subscribe(game.control.ui.progressDialogue)
    game.control.ui.spawnDialogue(dialogue, completeDialogue, false)
end

function dialogueEncounter.destroy()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
end

return dialogueEncounter
