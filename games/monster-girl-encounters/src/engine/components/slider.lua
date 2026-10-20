local slider = {
    type = 'Slider',
    onValueChange = engine.dofile('engine/event_receiver.lua'),
}

local _fillPath = 'fill'
local _handlePath = 'handle'
local _button
local _fill
local _handle
local _direction = 'leftToRight'
local _minValue = 0
local _maxValue = 1.0
local _wholeNumbers = false
local _value = 0
local _isDown = false
local _previousX = -9999
local _previousY = -9999

local function _adjustFill(w, h)
    if _fill == nil then
        return
    end
    local fillW, fillH = _fill.getSize()
    local percentage = (_value - _minValue) / (_maxValue - _minValue)
    if _direction == 'leftToRight' then
        _fill.setSize(w * percentage, fillH)
    elseif _direction == 'rightToLeft' then
        _fill.setSize(w * percentage, fillH)
    elseif _direction == 'bottomToTop' then
        _fill.setSize(fillW, h * percentage)
    else
        _fill.setSize(fillW, h * percentage)
    end
end

local function _adjustHandle(w, h)
    if _handle == nil then
        return
    end
    local x, y = _handle.getPosition()
    local percentage = (_value - _minValue) / (_maxValue - _minValue)
    if _direction == 'leftToRight' then
        _handle.setPosition(w * percentage, y)
    elseif _direction == 'rightToLeft' then
        _handle.setPosition(w * (1.0 - percentage), y)
    elseif _direction == 'bottomToTop' then
        _handle.setPosition(x, h * (1.0 - percentage))
    else
        _handle.setPosition(x, h * percentage)
    end
end

local function _refreshVisuals()
    local w, h = slider.object.getSize()
    _adjustFill(w, h)
    _adjustHandle(w, h)
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
        local min = objX
        local max = objX + w
        percentage = (x - min) / (max - min)
    elseif _direction == 'rightToLeft' then
        local min = objX + w
        local max = objX
        percentage = (x - min) / (max - min)
    elseif _direction == 'bottomToTop' then
        local min = objY + h
        local max = objY
        percentage = (y - min) / (max - min)
    else
        local min = objY
        local max = objY + h
        percentage = (y - min) / (max - min)
    end
    local value = ((_maxValue - _minValue) * percentage) + _minValue
    slider.setValue(value)
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
    if type(data.fill) == 'string' then
        _fillPath = data.fill
    end
    if type(data.handle) == 'string' then
        _handlePath = data.handle
    end
    if type(data.direction) == 'string' then
        _direction = data.direction
    end
    if type(data.minValue) == 'number' then
        _minValue = data.minValue
    end
    if type(data.maxValue) == 'number' then
        _maxValue = data.maxValue
    end
    if type(data.wholeNumbers) == 'boolean' then
        _wholeNumbers = data.wholeNumbers
    end
    if type(data.value) == 'number' then
        _value = data.value
    end
end

function slider.start()
    _button = slider.object.getComponent('button')
    _fill = slider.object.find(_fillPath)
    _handle = slider.object.find(_handlePath)
    _addButtonListeners()
    _refreshVisuals()
end

function slider.update()
    if _isDown then
        _updateMouse()
    end
    _refreshVisuals()
end

function slider.onDestroy()
    slider.onValueChange.clear()
    _clearButtonListeners()
end

function slider.setValue(value)
    if type(value) ~= 'number' then
        engine.debug.logError('Invalid setValue supplied to slider')
        return
    end
    value = math.min(value, _maxValue)
    value = math.max(value, _minValue)
    if _wholeNumbers then
        value = math.floor(value)
    end
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

function slider.setFill(fill)
    if fill == nil then
        _fill = nil
    elseif not engine.typeValidator.isGameType('Object', fill) then
        engine.debug.logError('Invalid setFill supplied to slider')
        return
    else
        _fill = fill
    end
    _refreshVisuals()
end

function slider.setHandle(handle)
    if handle ~= nil and not engine.typeValidator.isGameType('Object', handle) then
        engine.debug.logError('Invalid setHandle supplied to slider')
        return
    else
        _handle = handle
    end
    _refreshVisuals()
end

function slider.setDirection(direction)
    if type(direction) ~= 'string' then
        engine.debug.logError('Invalid setDirection supplied to slider')
        return
    end
    _direction = direction
    _refreshVisuals()
end

function slider.setWholeNumbers(wholeNumbers)
    if type(wholeNumbers) ~= 'boolean' then
        engine.debug.logError('Invalid setWholeNumbers supplied to slider')
        return
    end
    _wholeNumbers = wholeNumbers
end

function slider.setMinValue(minValue)
    if type(minValue) ~= 'number' then
        engine.debug.logError('Invalid setMinValue supplied to slider')
        return
    end
    _minValue = minValue
    _refreshVisuals()
end

function slider.getMinValue()
    return _minValue
end

function slider.setMaxValue(maxValue)
    if type(maxValue) ~= 'number' then
        engine.debug.logError('Invalid setMaxValue supplied to slider')
        return
    end
    _maxValue = maxValue
    _refreshVisuals()
end

function slider.getMaxValue()
    return _maxValue
end

function slider.setButton(button)
    if button ~= nil and not engine.typeValidator.isGameType('Button', button) then
        engine.debug.logError('Invalid button supplied to slider')
        return
    end
    _clearButtonListeners()
    _button = button
    _addButtonListeners()
end

return slider