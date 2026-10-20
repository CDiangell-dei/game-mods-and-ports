local textButton = {
    activeSprite = game.data.loadSprite('data/sprites/ui/button_active.png'),
    inactiveSprite = game.data.loadSprite('data/sprites/ui/button_inactive.png'),
    activeShadowColor = {
        r = 0.3333333,
        g = 0.3333333,
        b = 0.4431373,
        a = 1.0,
    },
    inactiveShadowColor = {
        r = 0.1411765,
        g = 0.145098,
        b = 0.2196079,
        a = 1.0,
    },
    mouseoverSound = 'data/sounds/general/mouseover.json',
    mouseDownSound = 'data/sounds/general/button_press.json',
    fadeTimer = 0.1
}

local _backgroundVisual = nil
local _shadowText = nil
local _hasInit = false
local _isOver = false
local _isDown = false
local _isSelected = false
local _isActivated = true
local _mouseoverFader = nil
local _mouseDownFader = nil

local function _setMouseoverOn()
    if _mouseoverFader ~= nil then
        _mouseoverFader.fadeTo(100, textButton.fadeTimer, nil)
    end
end

local function _setMouseoverOff()
    if _mouseoverFader ~= nil then
        _mouseoverFader.fadeTo(0, textButton.fadeTimer, nil)
    end
end

local function _setMouseDownOn()
    if _mouseDownFader ~= nil then
        _mouseDownFader.fadeTo(100, textButton.fadeTimer, nil)
    end
end

local function _setMouseDownOff()
    if _mouseDownFader ~= nil then
        _mouseDownFader.fadeTo(0, textButton.fadeTimer, nil)
    end
end

local function _setState()
    if _isOver and not _isDown then
        _setMouseoverOn()
        if _isSelected then
            _setMouseDownOn()
        else
            _setMouseDownOff()
        end
    elseif _isOver and _isDown then
        _setMouseoverOn()
        _setMouseDownOn()
    elseif not _isOver and _isDown then
        _setMouseoverOn()
        _setMouseDownOn()
    else
        _setMouseoverOff()
        if _isSelected then
            _setMouseDownOn()
        else
            _setMouseDownOff()
        end
    end
end

local function _mouseEnter()
    _isOver = true
    if not _isActivated then
        return
    end
    if textButton.mouseoverSound ~= nil then
        game.audio.playSound(textButton.mouseoverSound, nil, true)
    end
    _setState()
end

local function _mouseExit()
    _isOver = false
    if not _isActivated then
        return
    end
    _setState()
end

local function _mouseDown()
    _isDown = true
    if not _isActivated then
        game.audio.playSound('data/sounds/general/fail.json', nil, true)
        return
    end
    if textButton.mouseDownSound ~= nil then
        game.audio.playSound(textButton.mouseDownSound, nil, true)
    end
    _setState()
end

local function _mouseUp()
    _isDown = false
    if not _isActivated then
        return
    end
    _setState()
end

function textButton.init(object)
    if _hasInit then
        return
    end
    _hasInit = true
    if object == nil then
        game.debug.logWarning('Object nil in default_text_button\'s new()')
        return
    end
    local buttonObject = object.find('button')
    if buttonObject == nil then
        return
    end
    local buttonComponent = buttonObject.getComponent('button')
    if buttonComponent == nil then
        return
    end
    _backgroundVisual = buttonObject.getComponent('image')
    local outlineObject = object.find('outline')
    if outlineObject ~= nil then
        local outline = outlineObject.getComponent('mask')
        if outline ~= nil then
            _mouseDownFader = dofile('data/scripts/ui/dither_fader.lua')
            _mouseDownFader.init(outline, 0, true)
        end
    end
    local arrowObject = object.find('arrow')
    if arrowObject ~= nil then
        local arrow = arrowObject.getComponent('mask')
        if arrow ~= nil then
            _mouseoverFader = dofile('data/scripts/ui/dither_fader.lua')
            _mouseoverFader.init(arrow, 0, true)
        end
    end
    local shadowTextObject = object.find('label/shadow')
    if shadowTextObject ~= nil then
        _shadowText = shadowTextObject.getComponent('text')
    end
    buttonComponent.onMouseEnter.subscribe(_mouseEnter)
    buttonComponent.onMouseExit.subscribe(_mouseExit)
    buttonComponent.onMouseDown.subscribe(_mouseDown)
    buttonComponent.onMouseUp.subscribe(_mouseUp)
end

function textButton.select()
    _isSelected = true
    _setState()
end

function textButton.deselect()
    _isSelected = false
    _setState()
end

function textButton.deactivate()
    _isActivated = false
    if _backgroundVisual ~= nil then
        _backgroundVisual.setSprite(textButton.inactiveSprite)
    end
    if _shadowText ~= nil then
        _shadowText.setColor(textButton.inactiveShadowColor.r, textButton.inactiveShadowColor.g,
            textButton.inactiveShadowColor.b, textButton.inactiveShadowColor.a)
    end
    _setState()
end

function textButton.activate()
    _isActivated = true
    if _backgroundVisual ~= nil then
        _backgroundVisual.setSprite(textButton.activeSprite)
    end
    if _shadowText ~= nil then
        _shadowText.setColor(textButton.activeShadowColor.r, textButton.activeShadowColor.g,
            textButton.activeShadowColor.b, textButton.activeShadowColor.a)
    end
    _setState()
end

return textButton