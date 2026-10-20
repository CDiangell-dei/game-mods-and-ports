local button = {
    mouseoverSound = 'data/sounds/general/mouseover.json',
    mouseDownSound = 'data/sounds/general/button_press.json',
    mouseEnterColor = nil,
    defaultColor = nil,
    fadeTimer = 0.1
}

local _mouseoverFader = nil
local _hasInit = false
local _isOver = false
local _isDown = false
local _isSelected = false
local _isActivated = true
local _graphic = nil

local function _setMouseoverOn()
    if _mouseoverFader ~= nil then
        _mouseoverFader.fadeTo(100, button.fadeTimer, nil)
    end
    if button.mouseEnterColor ~= nil and _graphic ~= nil then
        _graphic.setColor(button.mouseEnterColor.r, button.mouseEnterColor.g,
            button.mouseEnterColor.b, button.mouseEnterColor.a)
    end
end

local function _setMouseoverOff()
    if _mouseoverFader ~= nil then
        _mouseoverFader.fadeTo(0, button.fadeTimer, nil)
    end
    if button.defaultColor ~= nil and _graphic ~= nil then
        _graphic.setColor(button.defaultColor.r, button.defaultColor.g,
            button.defaultColor.b, button.defaultColor.a)
    end
end

local function _setState()
    if not _isActivated then
        _setMouseoverOff()
        return
    end
    if _isSelected then
        _setMouseoverOn()
        return
    end
    if _isOver and not _isDown then
        _setMouseoverOn()
    elseif _isOver and _isDown then
        _setMouseoverOn()
    elseif not _isOver and _isDown then
        _setMouseoverOn()
    else
        _setMouseoverOff()
    end
end

local function _mouseEnter()
    _isOver = true
    if not _isActivated then
        return
    end
    if button.mouseoverSound ~= nil then
        game.audio.playSound(button.mouseoverSound, nil, true)
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
    if button.mouseDownSound ~= nil then
        game.audio.playSound(button.mouseDownSound, nil, true)
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

function button.init(object)
    if _hasInit then
        return
    end
    _hasInit = true
    if object == nil then
        game.debug.logWarning('Object nil in default_button\'s new()')
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
    _graphic = buttonObject.getComponent('image')
    local outlineObject = object.find('outline')
    if outlineObject ~= nil then
        local outline = outlineObject.getComponent('mask')
        if outline ~= nil then
            _mouseoverFader = dofile('data/scripts/ui/dither_fader.lua')
            _mouseoverFader.init(outline, 0, true)
        end
    end

    buttonComponent.onMouseEnter.subscribe(_mouseEnter)
    buttonComponent.onMouseExit.subscribe(_mouseExit)
    buttonComponent.onMouseDown.subscribe(_mouseDown)
    buttonComponent.onMouseUp.subscribe(_mouseUp)
end

function button.select()
    _isSelected = true
    _setState()
end

function button.deselect()
    _isSelected = false
    _setState()
end

function button.deactivate()
    _isActivated = false
    _setState()
end

function button.activate()
    _isActivated = true
    _setState()
end

return button