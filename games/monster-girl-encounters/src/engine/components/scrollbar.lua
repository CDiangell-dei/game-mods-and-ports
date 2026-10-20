local slider = {
    type = 'Scrollbar',
    onValueChange = engine.dofile('engine/event_receiver.lua'),
}

local _handlePath = 'handle'
local _button
local _image
local _handle
local _handleImage = nil
local _size = 1.0
local _direction = 'topToBottom'
local _value = 0
local _isDown = false
local _previousX = -9999
local _previousY = -9999
local _originalColor = { r=1, g=1, b=1, a=1 }
local _originalHandleColor = { r=1, g=1, b=1, a=1 }
local _isVisible = true

local function _refreshVisuals()
    if _handle == nil then
        return
    end
    local x, y = _handle.getPosition()
    local w, h = slider.object.getSize()
    if _direction == 'leftToRight' then
        local center = w * 0.5
        local range = (w - (w * _size)) * 0.5
        local min = center - range
        local max = center + range
        local pos = min + ((max - min) * _value)
        _handle.setSize(w * _size, h)
        _handle.setPosition(pos, y)
    elseif _direction == 'rightToLeft' then
        local center = w * 0.5
        local range = (w - (w * _size)) * 0.5
        local min = center + range
        local max = center - range
        local pos = min + ((max - min) * _value)
        _handle.setSize(w * _size, h)
        _handle.setPosition(pos, y)
    elseif _direction == 'bottomToTop' then
        local center = h * 0.5
        local range = (h - (h * _size)) * 0.5
        local min = center + range
        local max = center - range
        local pos = min + ((max - min) * _value)
        _handle.setSize(w, h * _size)
        _handle.setPosition(x, pos)
    else
        local center = h * 0.5
        local range = (h - (h * _size)) * 0.5
        local min = center - range
        local max = center + range
        local pos = min + ((max - min) * _value)
        _handle.setSize(w, h * _size)
        _handle.setPosition(x, pos)
    end
end

local function _updateMouse()
    local x, y = engine.input.getMousePosition()
    if x == _previousX and y == _previousY then
        return
    end
    _previousX = x
    _previousY = y
    local objX, objY = slider.object.getActualPosition()
    local w, h = slider.object.getSize()
    local percentage
    if _direction == 'leftToRight' then
        local center = objX + (w * 0.5)
        local range = w * (1.0 - _size) * 0.5
        if range <= 0 then
            percentage = 1.0
        else
            local min = center - range
            local max = center + range
            percentage = (x - min) / (max - min)
        end
    elseif _direction == 'rightToLeft' then
        local center = objX + (w * 0.5)
        local range = w * (1.0 - _size) * 0.5
        if range <= 0 then
            percentage = 1.0
        else
            local min = center + range
            local max = center - range
            percentage = (x - min) / (max - min)
        end
    elseif _direction == 'bottomToTop' then
        local center = objY + (h * 0.5)
        local range = h * (1.0 - _size) * 0.5
        if range <= 0 then
            percentage = 1.0
        else
            local min = center + range
            local max = center - range
            percentage = (y - min) / (max - min)
        end
    else
        local center = objY + (h * 0.5)
        local range = h * (1.0 - _size) * 0.5
        if range <= 0 then
            percentage = 1.0
        else
            local min = center - range
            local max = center + range
            percentage = (y - min) / (max - min)
        end
    end
    slider.setValue(percentage)
end

local function _mouseDown()
    _isDown = true
    _updateMouse()
end

local function _mouseUp()
    _isDown = false
    _previousX = -9999
    _previousY = -9999
end

local function _clearButtonListeners()
    if _button == nil then
        return
    end
    _button.onMouseDown.unsubscribe(_mouseDown)
    _button.onMouseUp.unsubscribe(_mouseUp)
end

local function _addButtonListeners()
    if _button == nil then
        return
    end
    _button.onMouseDown.subscribe(_mouseDown)
    _button.onMouseUp.subscribe(_mouseUp)
end

function slider.populateFromData(data)
    if type(data.direction) == 'string' then
        _direction = data.direction
    end
    if type(data.value) == 'number' then
        _value = data.value
    end
    if type(data.handle) == 'string' then
        _handlePath = data.handle
    end
end

function slider.update()
    if _isDown then
        _updateMouse()
    end
    _refreshVisuals()
end

function slider.start()
    _handle = slider.object.find(_handlePath)
    _button = slider.object.getComponent('button')
    _image = slider.object.getComponent('image')
    if _handle ~= nil then
        _handleImage = _handle.getComponent('image')
    end
    _addButtonListeners()
    _refreshVisuals()
end

function slider.onDestroy()
    slider.onValueChange.clear()
    _clearButtonListeners()
end

function slider.setValue(value)
    if type(value) ~= 'number' then
        engine.debug.logError('Invalid value supplied to scrollbar.')
        return
    end
    value = math.min(value, 1.0)
    value = math.max(value, 0)
    if value == _value then
        return
    end
    _value = value
    _refreshVisuals()
    slider.onValueChange.invoke(value)
end

function slider.getValue()
    return _value
end

function slider.setHandle(handle)
    if handle ~= nil and not engine.typeValidator.isGameType('Object', handle) then
        engine.debug.logError('Invalid setHandle supplied to scrollbar.')
        return
    end
    _handle = handle
    _isVisible = true
    _refreshVisuals()
end

function slider.setSize(percentage)
    if type(percentage) ~= 'number' then
        engine.debug.logError('Invalid setSize supplied to scrollbar.')
        return
    end
    _size = percentage
    _refreshVisuals()
end

function slider.setDirection(direction)
    if type(direction) ~= 'string' then
        engine.debug.logError('Invalid direction supplied to scrollbar.')
        return
    end
    _direction = direction
    _refreshVisuals()
end

function slider.setButton(button)
    if button ~= nil and not engine.typeValidator.isGameType('Button', button) then
        engine.debug.logError('Invalid button supplied to scrollbar')
        return
    end
    _clearButtonListeners()
    _button = button
    _addButtonListeners()
end

function slider.setVisible(isVisible)
    if type(isVisible) ~= 'boolean' then
        engine.debug.logError('Invalid setVisible supplied to scrollbar')
        return
    end
    if isVisible == _isVisible then
        return
    end
    _isVisible = isVisible
    if _isVisible then
        if _image ~= nil then
            _image.setColor(_originalColor.r, _originalColor.g, _originalColor.b, _originalColor.a)
        end
        if _handleImage ~= nil then
            _handleImage.setColor(_originalHandleColor.r, _originalHandleColor.g,
                _originalHandleColor.b, _originalHandleColor.a)
        end
    else
        if _image ~= nil then
            local r, g, b, a = _image.getColor()
            _originalColor = {r = r, g = g, b = b, a = a}
            _image.setColor(0, 0, 0, 0)
        end
        if _handleImage ~= nil then
            local r, g, b, a = _handleImage.getColor()
            _originalHandleColor = {r = r, g = g, b = b, a = a}
            _handleImage.setColor(0, 0, 0, 0)
        end
    end
    _refreshVisuals()
end

return slider