local text = {
    type = 'Text',
}

local _delimiters = {
    '<color=.->',
    '</color>',
}
local _persist = engine.require('engine/components/persistent_data.lua')
local _isDestroyed = false
local _color = {
    r = 1.0,
    g = 1.0,
    b = 1.0,
    a = 1.0,
}
local _isMaskable = true
local _textKey = ''
local _text = ''
local _isRichText = true
local _parsedText = nil
local _visibleText = {}
local _wrapAmount = 0
local _font = engine.graphics.getDefaultFont(12)
local _wrapText = false
local _horizontalAlignment = 'center'
local _verticalAlignment = 'middle'
local _maxVisibleCharacters = -1
local _controlObjectSize = false
local _renderedText = love.graphics.newText(_font, '')
local _ignoreTranslation = false
local _forceColor = false

local function _getTextPosition(t)
    local x, y = text.object.getActualPosition()
    local sx, sy = text.object.getSize()
    local height = t:getHeight()
    local yPos
    if _verticalAlignment == 'middle' then
        yPos = ((sy - height) * 0.5) + y
    elseif _verticalAlignment == 'bottom' then
        yPos = y + sy - height
    else
        yPos = y
    end
    local xPos
    if _horizontalAlignment == 'center' then
        xPos = x - ((_wrapAmount - sx) * 0.5)
    elseif _horizontalAlignment == 'right' then
        xPos = x - (_wrapAmount - sx)
    else
        xPos = x
    end
    xPos = math.floor(xPos)
    yPos = math.floor(yPos)
    return xPos, yPos
end

local function _draw()
    if _font == nil then
        return
    end
    local x, y = _getTextPosition(_renderedText)
    if _isMaskable then
        love.graphics.setStencilTest('equal', _persist.maskCount)
    end
    local offsetX, offsetY = engine.graphics.getScaledOffset()
    love.graphics.draw(_renderedText, x + offsetX, y + offsetY)
    love.graphics.setStencilTest()
end

local function _tryRefreshObjectSize()
    if not _controlObjectSize then
        return
    end
    if _font == nil then
        text.object.setSize(0, 0)
        return
    end
    local h = _renderedText:getHeight()
    local w, _ = text.object.getSize()
    text.object.setSize(w, h)
end

local function _refreshVisibleText()
    if _renderedText == nil then
        return
    end
    if _parsedText == nil then
        _renderedText:setf('', 1, _horizontalAlignment)
        _tryRefreshObjectSize()
        return
    end
    local parsedTextCount = #_parsedText
    local visibleCount = #_visibleText
    for i=1, visibleCount do
        _visibleText[i] = nil
    end
    local maxCount = _maxVisibleCharacters * 2
    for i=1, parsedTextCount do
        _visibleText[i] = _parsedText[i]
        local isColor = i % 2 == 1
        if isColor and maxCount > -1 and i > maxCount then
            local col = {}
            col[1] = _parsedText[i][1]
            col[2] = _parsedText[i][2]
            col[3] = _parsedText[i][3]
            col[4] = 0
            _visibleText[i] = col
        end
    end
    if _wrapText then
        local sx, _ = text.object.getSize()
        _wrapAmount = sx
        if _wrapAmount <= 1 then
            _wrapAmount = 6
        end
    else
        _wrapAmount = 9999
    end
    _renderedText:setf(_visibleText, _wrapAmount, _horizontalAlignment)

    _tryRefreshObjectSize()
end

local function _parseChunk(chunk)
    if engine.string.sub(chunk, 1, 1) ~= '<' then
        return nil
    end
    local delimiter = string.match(chunk, '<(.-)=')
    if delimiter == nil then
        delimiter = string.match(chunk, '<(.-)>')
        return delimiter
    end
    local variable = string.match(chunk, '=(.-)>')
    return delimiter, variable
end

local function _getColor(key)
    local code = engine.graphics.getColor(key)
    if code ~= nil then
        return engine.graphics.hexToColor(code)
    else
        return engine.graphics.hexToColor(key)
    end
end

local function _refreshParsedText()
    if _text == '' then
        _parsedText = nil
        _refreshVisibleText()
        return
    end
    _parsedText = {}
    local cols = {
        { _color.r, _color.g, _color.b, _color.a },
    }
    if not _isRichText then
        table.insert(_parsedText, cols[1])
        table.insert(_parsedText, _text)
        _refreshVisibleText()
        return
    end
    local chunks = engine.string.splitWithDelimiters(_text, _delimiters)
    for i=1, #chunks do
        local chunk = chunks[i]
        local delim, variable = _parseChunk(chunk)
        if delim == 'color' then
            if not _forceColor then
                local r, g, b, a = _getColor(variable)
                local col = {r, g, b, a}
                table.insert(cols, col)
            end
        elseif delim == '/color' then
            if not _forceColor then
                if #cols > 1 then
                    cols[#cols] = nil
                end
            end
        else
            local activeColor = cols[#cols]
            for _, code in engine.string.codes(chunk) do
                local c = engine.string.char(code)
                table.insert(_parsedText, activeColor)
                table.insert(_parsedText, c)
            end
        end
    end
    _refreshVisibleText()
end

local function _refreshLanguage()
    text.setText(_textKey)
end

function text.populateFromData(data)
    if type(data.overlay) == 'boolean' then
        text.setOverlay(data.overlay)
    end
    if type(data.richText) == 'boolean' then
        _isRichText = data.richText
    end
    if type(data.color) == 'string' then
        local r, g, b, a = _getColor(data.color)
        _color.r = r
        _color.g = g
        _color.b = b
        _color.a = a
    end
    if type(data.maxVisibleCharacters) == 'number' then
        _maxVisibleCharacters = data.maxVisibleCharacters
    end
    if type(data.maskable) == 'boolean' then
        _isMaskable = data.maskable
    end
    if type(data.horizontalAlignment) == 'string' then
        _horizontalAlignment = data.horizontalAlignment
    end
    if type(data.verticalAlignment) == 'string' then
        _verticalAlignment = data.verticalAlignment
    end
    if type(data.font) == 'string' and type(data.size) == 'number' then
        _font = engine.fileSystem.loadFont(data.font, data.size)
        _font = _font or engine.graphics.getDefaultFont(data.size)
        _renderedText:setFont(_font)
    elseif type(data.size) == 'number' then
        _font = engine.graphics.getDefaultFont(data.size)
        _renderedText:setFont(_font)
    end
    if type(data.wrap) == 'boolean' then
        _wrapText = data.wrap
    end
    if type(data.controlObjectSize) == 'boolean' then
        _controlObjectSize = data.controlObjectSize
    end
    if type(data.ignoreTranslation) == 'boolean' then
        _ignoreTranslation = data.ignoreTranslation
    end
    if type(data.forceColor) == 'boolean' then
        _forceColor = data.forceColor
    end
    if type(data.text) == 'string' then
        _textKey = data.text
    end
end

text.draw = _draw

function text.start()
    engine.events.subscribe('refreshLanguage', _refreshLanguage)
    text.setText(_textKey)
end

function text.onDestroy()
    _isDestroyed = true
    _font = nil
    _renderedText = nil
    engine.events.unsubscribe('refreshLanguage', _refreshLanguage)
end

function text.setOverlay(isOverlay)
    if type(isOverlay) ~= 'boolean' then
        engine.debug.logError('Invalid setOverlay supplied to text')
        return
    end
    if isOverlay then
        text.overlay = _draw
        text.draw = nil
    else
        text.draw = _draw
        text.overlay = nil
    end
end

function text.setColor(r, g, b, a)
    if type(r) ~= 'number' or type(g) ~= 'number' or type(b) ~= 'number' then
        engine.debug.logError('Invalid color supplied to text.')
        return
    end
    if type(a) ~= 'number' then
        a = 1.0
    end
    _color.r = r
    _color.g = g
    _color.b = b
    _color.a = a
    _refreshParsedText()
end

function text.getColor()
    return _color.r, _color.g, _color.b, _color.a
end

function text.setRichText(isRichText)
    if type(isRichText) ~= 'boolean' then
        engine.debug.logError('Invalid setRichText supplied to text.')
        return
    end
    _isRichText = isRichText
    _refreshParsedText()
end

function text.getRichText()
    return _isRichText
end

function text.setMaskable(isMaskable)
    if type(isMaskable) ~= 'boolean' then
        engine.debug.logError('Invalid setMaskable supplied to text.')
        return
    end
    _isMaskable = isMaskable
end

function text.getMaskable()
    return _isMaskable
end

function text.setControlObjectSize(adjusts)
    if type(adjusts) ~= 'boolean' then
        engine.debug.logError('Invalid setControlObjectSize supplied to text.')
        return
    end
    _controlObjectSize = adjusts
    _tryRefreshObjectSize()
end

function text.getControlObjectSize()
    return _controlObjectSize
end

function text.setFont(font)
    if _isDestroyed then
        return
    end
    if _font == nil then
        _font = engine.graphics.getDefaultFont(canvas.defaultFontSize)
    elseif not engine.typeValidator.isFont(font) then
        engine.debug.logError('Invalid font supplied to text.')
        return
    else
        _font = font
    end
    _renderedText:setFont(_font)
    _tryRefreshObjectSize()
end

function text.getFont()
    return _font
end

function text.setText(t)
    if _isDestroyed then
        return
    end
    if t == nil then
        t = ''
    elseif type(t) ~= 'string' then
        engine.debug.logError('Invalid setText supplied to text.')
        return
    end
    if _ignoreTranslation then
        _text = t
        _textKey = t
    else
        local translation = engine.translator.getText(t)
        _text = translation
        _textKey = t
    end
    _refreshParsedText()
end

function text.getText()
    return _text
end

function text.getParsedTextLength()
    if _parsedText == nil then
        return 0
    end
    if not _isRichText then
        return engine.string.len(_text)
    end
    local count = #_parsedText
    count = count * 0.5
    count = math.floor(count + 0.5)
    return count
end

function text.setHorizontalAlignment(alignment)
    if _isDestroyed then
        return
    end
    if type(alignment) ~= 'string' then
        engine.debug.logError('Invalid setHorizontalAlignment supplied to text.')
        return
    end
    _horizontalAlignment = alignment
    _refreshVisibleText()
end

function text.getHorizontalAlignment()
    return _horizontalAlignment
end

function text.setVerticalAlignment(alignment)
    if type(alignment) ~= 'string' then
        engine.debug.logError('Invalid setVerticalAlignment supplied to text.')
        return
    end
    _verticalAlignment = alignment
end

function text.getVerticalAlignment()
    return _verticalAlignment
end

function text.setMaxVisibleCharacters(amount)
    if _isDestroyed then
        return
    end
    if type(amount) ~= 'number' then
        engine.debug.logError('Invalid setMaxVisibleCharacters supplied to text.')
        return
    end
    _maxVisibleCharacters = amount
    _refreshVisibleText()
end

function text.getMaxVisibleCharacters()
    return _maxVisibleCharacters
end

function text.setTextWrap(wraps)
    if _isDestroyed then
        return
    end
    if type(wraps) ~= 'boolean' then
        engine.debug.logError('Invalid setTextWrap supplied to text.')
        return
    end
    _wrapText = wraps
    _refreshVisibleText()
end

function text.getTextWrap()
    return _wrapText
end

function text.setForceColor(forced)
    if type(forced) ~= 'boolean' then
        engine.debug.logError('Invalid setForceColor supplied to text.')
        return
    end
    _forceColor = forced
end

return text