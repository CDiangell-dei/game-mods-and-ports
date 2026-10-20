local scrollView = {
    type = 'ScrollView',
}

local _viewportPath = 'viewport'
local _contentPath = 'viewport/content'
local _scrollbarPath = 'scrollbar'
local _button
local _scrollbar
local _viewport
local _content
local _isDown = false
local _isOver = false
local _previousY = 0
local _value = 0
local _sensitivity = 30
local _autoHideScrollbar = true
local _preventMovement = true
-- MOD (touch fix): a real mouse click barely moves before release, but a
-- finger tap on a touchscreen almost always drifts a few pixels. Without a
-- deadzone, that drift was being read as "start scrolling", which stole taps
-- away from buttons/toggles inside the scroll view. Movement below this
-- many pixels (accumulated from mouse-down) is ignored entirely.
local _touchDeadzone = 10
local _downX = 0
local _downY = 0
local _deadzonePassed = false

local function _refreshVisuals()
    if _viewport == nil or _content == nil then
        return
    end
    local _, contentY = _content.getSize()
    local _, viewportY = _viewport.getSize()
    _preventMovement = contentY <= viewportY
    if _scrollbar ~= nil then
        if _autoHideScrollbar then
            _scrollbar.setVisible(contentY > viewportY)
        else
            _scrollbar.setVisible(true)
        end
        local scale = viewportY / contentY
        if scale >= 1.0 then
            _scrollbar.setSize(1.0)
        else
            _scrollbar.setSize(scale)
        end
    end
    local maxY = contentY - viewportY
    local x, _ = _content.getPosition()
    local _, contentPivot = _content.getPivot()
    local y = (-maxY * _value) + (viewportY * contentPivot)
    _content.setPosition(x, y)
end

local function _updateMouse()
    local x, y = engine.input.getMousePosition()
    if not _deadzonePassed then
        local totalDistance = math.sqrt((x - _downX) ^ 2 + (y - _downY) ^ 2)
        if totalDistance < _touchDeadzone then
            return
        end
        _deadzonePassed = true
        _previousY = y --start measuring scroll delta fresh from here, ignore the deadzone jump
    end
    if y == _previousY then
        return
    end
    local difference = y - _previousY
    _previousY = y
    if _viewport == nil or _content == nil then
        return
    end
    local _, contentY = _content.getSize()
    local _, viewportY = _viewport.getSize()
    _value = _value - (difference / (contentY - viewportY))
    _value = math.min(_value, 1.0)
    _value = math.max(_value, 0.0)
    if _scrollbar ~= nil then
        _scrollbar.setValue(_value)
    end
end

local function _mouseDown()
    if _preventMovement then
        return
    end
    local x, y = engine.input.getMousePosition()
    _previousY = y
    _downX = x
    _downY = y
    _deadzonePassed = false
    if _scrollbar ~= nil then
        _value = _scrollbar.getValue()
    end
    _isDown = true
end

local function _mouseUp()
    _isDown = false
end

local function _onEnter()
    _isOver = true
end

local function _onExit()
    _isOver = false
end

local function _clearButtonListeners()
    if _button == nil then
        return
    end
    _button.onMouseDown.unsubscribe(_mouseDown)
    _button.onMouseUp.unsubscribe(_mouseUp)
    _button.onMouseEnter.unsubscribe(_onEnter)
    _button.onMouseExit.unsubscribe(_onExit)
end

local function _addButtonListeners()
    if _button == nil then
        return
    end
    _button.onMouseDown.subscribe(_mouseDown)
    _button.onMouseUp.subscribe(_mouseUp)
    _button.onMouseEnter.subscribe(_onEnter)
    _button.onMouseExit.subscribe(_onExit)
end

local function _scroll(value)
    if _preventMovement then
        return
    end
    if _isDown or not _isOver or _content == nil then
        return
    end
    local _, contentY = _content.getSize()
    _value = _value - ((_sensitivity / contentY) * value)
    _value = math.min(_value, 1.0)
    _value = math.max(_value, 0.0)
    if _scrollbar ~= nil then
        _scrollbar.setValue(_value)
    end
end

function scrollView.populateFromData(data)
    if type(data.scrollbar) == 'string' then
        _scrollbarPath = data.scrollbar
    end
    if type(data.viewport) == 'string' then
        _viewportPath = data.viewport
    end
    if type(data.content) == 'string' then
        _contentPath = data.content
    end
    if type(data.sensitivity) == 'number' then
        _sensitivity = data.sensitivity
    end
end

function scrollView.update()
    if _isDown then
        _updateMouse()
    elseif _scrollbar ~= nil then
        _value = _scrollbar.getValue()
    end
    _refreshVisuals()
end

function scrollView.start()
    _viewport = scrollView.object.find(_viewportPath)
    _content = scrollView.object.find(_contentPath)
    _button = scrollView.object.getComponent('button')
    local sb = scrollView.object.find(_scrollbarPath)
    if sb ~= nil then
        scrollView.setScrollbar(sb.getComponent('scrollbar'))
    end
    _addButtonListeners()
    engine.events.subscribe('scroll', _scroll)
    _refreshVisuals()
end

function scrollView.onDestroy()
    engine.events.unsubscribe('scroll', _scroll)
    _clearButtonListeners()
end

function scrollView.setScrollbar(scrollbar)
    if scrollbar == nil then
        _scrollbar = nil
    elseif not engine.typeValidator.isGameType('Scrollbar', scrollbar) then
        engine.debug.logError('Invalid scrollbar supplied to scrollView')
        return
    else
        _scrollbar = scrollbar
    end
    _refreshVisuals()
end

function scrollView.setViewport(viewport)
    if viewport == nil then
        _viewport = nil
    elseif not engine.typeValidator.isGameType('Object', viewport) then
        engine.debug.logError('Invalid viewport supplied to scrollView')
        return
    else
        _viewport = viewport
    end
    _refreshVisuals()
end

function scrollView.setContent(content)
    if content == nil then
        _content = nil
    elseif not engine.typeValidator.isGameType('Object', content) then
        engine.debug.logError('Invalid viewport supplied to scrollView')
        return
    else
        _content = content
    end
    _content = content
    _refreshVisuals()
end

function scrollView.setButton(button)
    if button ~= nil and not engine.typeValidator.isGameType('Button', button) then
        engine.debug.logError('Invalid button supplied to scrollView')
        return
    end
    _clearButtonListeners()
    _button = button
    _addButtonListeners()
end

function scrollView.setSensitivity(sensitivity)
    if type(sensitivity) ~= 'number' then
        engine.debug.logError('Invalid sensitivity supplied to scrollView')
        return
    end
    _sensitivity = sensitivity
end

function scrollView.setAutoHideScrollbar(autoHide)
    if type(autoHide) ~= 'boolean' then
        engine.debug.logError('Invalid setAutoHideScrollbar supplied to scrollView')
        return
    end
    _autoHideScrollbar = autoHide
end

return scrollView