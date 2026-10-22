local highlightButton = {
    mouseoverSound = 'data/sounds/general/mouseover.json',
    mouseDownSound = 'data/sounds/general/button_press.json',
    mouseEnterColor = nil,
    defaultColor = nil,
    fadeTimer = 0.1
}

local _hasInit = false
local _isOver = false
local _isDown = false
local _isSelected = false
local _isActivated = true
local _isIndicating = false
local _mouseoverFader = nil
local _mouseDownFader = nil
local _graphic = nil
local _fadeGoal = 100

local function _continueIndication(forceIndication)
    if _mouseDownFader == nil then
        return
    end
    local alpha = _mouseDownFader.getAlpha()
    if alpha == _fadeGoal then
        if _fadeGoal == 0 then
            _fadeGoal = 100
        else
            _fadeGoal = 0
        end
    end
    local time
    if forceIndication == true then
        time = 0.1
        _fadeGoal = 100
    else
        time = math.abs(alpha - _fadeGoal) * 0.01
    end
    _mouseDownFader.fadeTo(_fadeGoal, time, _continueIndication)
end

local function _setMouseoverOn()
    if _mouseoverFader ~= nil then
        _mouseoverFader.fadeTo(100, highlightButton.fadeTimer, nil)
    end
    if highlightButton.mouseEnterColor ~= nil and _graphic ~= nil then
        _graphic.setColor(highlightButton.mouseEnterColor.r, highlightButton.mouseEnterColor.g,
            highlightButton.mouseEnterColor.b, highlightButton.mouseEnterColor.a)
    end
end

local function _setMouseoverOff()
    if _mouseoverFader ~= nil then
        _mouseoverFader.fadeTo(0, highlightButton.fadeTimer, nil)
    end
    if highlightButton.defaultColor ~= nil and _graphic ~= nil then
        _graphic.setColor(highlightButton.defaultColor.r, highlightButton.defaultColor.g,
            highlightButton.defaultColor.b, highlightButton.defaultColor.a)
    end
end

local function _setMouseDownOn()
    if _mouseDownFader ~= nil then
        _mouseDownFader.fadeTo(100, highlightButton.fadeTimer, nil)
        _fadeGoal = 100
    end
end

local function _setMouseDownOff()
    if _mouseDownFader ~= nil then
        _mouseDownFader.fadeTo(0, highlightButton.fadeTimer, nil)
        _fadeGoal = 0
    end
end

local function _setState(forceIndication)
    if not _isActivated then
        _setMouseDownOff()
        _setMouseoverOff()
        return
    end

    if _isDown or _isSelected then
        _setMouseDownOn()
    elseif _isIndicating then
        _continueIndication(forceIndication)
    else
        _setMouseDownOff()
    end

    if _isOver or _isDown then
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
    if highlightButton.mouseoverSound ~= nil then
        game.audio.playSound(highlightButton.mouseoverSound, nil, true)
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
    if highlightButton.mouseDownSound ~= nil then
        game.audio.playSound(highlightButton.mouseDownSound, nil, true)
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

function highlightButton.init(object)
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
    _graphic = buttonObject.getComponent('image')
    local mouseDownObject = object.find('mouseDown')
    if mouseDownObject ~= nil then
        local mouseDown = mouseDownObject.getComponent('mask')
        if mouseDown ~= nil then
            _mouseDownFader = dofile('data/scripts/ui/dither_fader.lua')
            _mouseDownFader.init(mouseDown, 0, true)
        end
    end
    local mouseoverObject = object.find('mouseover')
    if mouseoverObject ~= nil then
        local mouseover = mouseoverObject.getComponent('mask')
        if mouseover ~= nil then
            _mouseoverFader = dofile('data/scripts/ui/dither_fader.lua')
            _mouseoverFader.init(mouseover, 0, true)
        end
    end

    buttonComponent.onMouseEnter.subscribe(_mouseEnter)
    buttonComponent.onMouseExit.subscribe(_mouseExit)
    buttonComponent.onMouseDown.subscribe(_mouseDown)
    buttonComponent.onMouseUp.subscribe(_mouseUp)
end

function highlightButton.select()
    _isSelected = true
    _setState()
end

function highlightButton.deselect()
    _isSelected = false
    _setState()
end

function highlightButton.deactivate()
    _isActivated = false
    _setState()
end

function highlightButton.activate()
    _isActivated = true
    _setState()
end

function highlightButton.indicate()
    _isIndicating = true
    _fadeGoal = 0
    _setState(true)
end

function highlightButton.stopIndicate()
    _isIndicating = false
    _setState(true)
end

return highlightButton
