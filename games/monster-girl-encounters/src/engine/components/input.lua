local input = {
    type = 'Input',
    onInputChange = engine.dofile('engine/event_receiver.lua'),
    onEndInput = engine.dofile('engine/event_receiver.lua'),
}

local _persist = engine.require('engine/components/persistent_data.lua')
local _textComponentPath = 'area/text'
local _placeholderPath = 'area/placeholder'
local _imeColor = 'ffffff'
local _text
local _placeholder
local _previousColor = {}
local _button = nil
local _characterLimit = 0
local _isEditing = false
local _isOver = false
local _isBackspacing = false
local _backspaceTimer = 0.5
local _characters = {}
local _value = ''
local _imeText = ''

local function _refreshText()
    local s = table.concat(_characters)
    local editingS
    if _imeText ~= '' then
        local output = {}
        table.insert(output, s)
        table.insert(output, '<color=')
        table.insert(output, _imeColor)
        table.insert(output, '>')
        table.insert(output, _imeText)
        table.insert(output, '</color>')
        editingS = table.concat(output)
    else
        editingS = s
    end
    if _text ~= nil then
        _text.setText(editingS)
    end
    _value = s
    input.onInputChange.invoke(s)
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
    _button.onMouseEnter.unsubscribe(_onEnter)
    _button.onMouseExit.unsubscribe(_onExit)
end

local function _addButtonListeners()
    if _button == nil then
        return
    end
    _button.onMouseEnter.subscribe(_onEnter)
    _button.onMouseExit.subscribe(_onExit)
end

local function _startInput()
    if _placeholder ~= nil then
        local r, g, b, a = _placeholder.getColor()
        _previousColor.r = r
        _previousColor.g = g
        _previousColor.b = b
        _previousColor.a = a
        _placeholder.setColor(0, 0, 0, 0)
    end
    _isEditing = true
    _persist.activeInputCount = _persist.activeInputCount + 1
    if _persist.activeInputCount == 1 then
        engine.input.startInput()
    end
end

local function _completeInput()
    _isBackspacing = false
    if _placeholder ~= nil and #_characters < 1 then
        _placeholder.setColor(_previousColor.r, _previousColor.g, _previousColor.b, _previousColor.a)
    end
    _isEditing = false
    _persist.activeInputCount = _persist.activeInputCount - 1
    if _persist.activeInputCount == 0 then
        engine.input.stopInput()
    end
    local s = table.concat(_characters)
    _value = s
    input.onEndInput.invoke(s)
end

local function _receiveMousePress(mouseButton)
    if mouseButton ~= 1 then
        return
    end
    if _isEditing and not _isOver then
        _completeInput()
    elseif not _isEditing and _isOver then
        _startInput()
    end
end

local function _receiveInput(s)
    if not _isEditing then
        return
    end
    if _characterLimit > 0 and #_characters >= _characterLimit then
        return
    end
    table.insert(_characters, s)
    _imeText = ''
    _refreshText()
end

local function _receiveIMEText(s, _, _)
    _imeText = s
    _refreshText()
end

local function _backspace()
    local count = #_characters
    if count < 1 then
        return
    end
    _characters[count] = nil
    _refreshText()
end

local function _verifyKey(scancode)
    if not _isEditing then
        return
    end
    if scancode == 'return' or scancode == 'escape' then
        _completeInput()
    elseif scancode == 'backspace' then
        _backspaceTimer = 0.5
        _isBackspacing = true
        _backspace()
    end
end

local function _verifyRelease(scancode)
    if not _isBackspacing then
        return
    end
    if scancode == 'backspace' then
        _isBackspacing = false
    end
end

local function _setTextFromObject(obj)
    if obj == nil then
        input.setTextComponent(nil)
    else
        input.setTextComponent(obj.getComponent('text'))
    end
end

local function _setPlaceholderFromObject(obj)
    if obj == nil then
        input.setPlaceholder(nil)
        return
    end
    local text = obj.getComponent('text')
    if text ~= nil then
        input.setPlaceholder(text)
        return
    end
    local image = obj.getComponent('image')
    input.setPlaceholder(image)
end

function input.populateFromData(data)
    if type(data.textComponent) == 'string' then
        _textComponentPath = data.textComponent
    end
    if type(data.placeholder) == 'string' then
        _placeholderPath = data.placeholder
    end
    if type(data.characterLimit) == 'number' then
        _characterLimit = data.characterLimit
    end
    if type(data.imeColor) == 'string' then
        _imeColor = data.imeColor
    end
end

function input.update()
    if not _isBackspacing then
        return
    end
    local dt = engine.timer.getUnscaledDeltaTime()
    _backspaceTimer = _backspaceTimer - dt
    if _backspaceTimer > 0 then
        return
    end
    _backspaceTimer = _backspaceTimer + (1.0 / 30.0)
    _backspace()
end

function input.start()
    _setTextFromObject(input.object.find(_textComponentPath))
    _setPlaceholderFromObject(input.object.find(_placeholderPath))
    _button = input.object.getComponent('button')
    _addButtonListeners()
    engine.events.subscribe('textInput', _receiveInput)
    engine.events.subscribe('textEdited', _receiveIMEText)
    engine.events.subscribe('keyPressed', _verifyKey)
    engine.events.subscribe('keyReleased', _verifyRelease)
    engine.events.subscribe('mousePressed', _receiveMousePress)
end

function input.onDestroy()
    _clearButtonListeners()
    engine.events.unsubscribe('textInput', _receiveInput)
    engine.events.unsubscribe('textEdited', _receiveIMEText)
    engine.events.unsubscribe('keyPressed', _verifyKey)
    engine.events.unsubscribe('keyReleased', _verifyRelease)
    engine.events.unsubscribe('mousePressed', _receiveMousePress)
end

function input.getText()
    return _value
end

function input.setTextComponent(textComponent)
    if textComponent == nil then
        _text = nil
        return
    elseif not engine.typeValidator.isGameType('Text', textComponent) then
        engine.debug.logError('Invalid textComponent supplied to input.')
        return
    end
    _text = textComponent
end

function input.setPlaceholder(placeholder)
    if placeholder == nil then
        _placeholder = nil
        return
    elseif not engine.typeValidator.isGameType('Drawable', placeholder) then
        engine.debug.logError('Invalid placeholder supplied to input.')
        return
    end
    _placeholder = placeholder
end

function input.setCharacterLimit(characterLimit)
    if type(characterLimit) ~= 'number' then
        engine.debug.logError('Invalid characterLimit supplied to input.')
        return
    end
    _characterLimit = characterLimit
end

function input.getCharacterLimit()
    return _characterLimit
end

function input.setIMEColor(col)
    if type(col) ~= 'string' then
        engine.debug.logError('Invalid setIMEColor supplied to input.')
        return
    end
    _imeColor = col
end

return input