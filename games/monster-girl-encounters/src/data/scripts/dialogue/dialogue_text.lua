local dialogueText = {}

local _pendingProgress = false
local _isWaiting = false
local _currentChunks
local _currentVisibleCharacters = 0
local _currentParsedLength = 0
local _autoTimer = 2.0
local _talkTimer = 0
local _sound
local _next
local _text
local _shadowText
local _progressIndicator
local _currentText = ''
local _callbacks = {
    ['script'] = dofile,
    ['pause'] = 1,
}
local _ignore = {
    '(<color=.->)',
    '(</color>)'
}
local _delimiters = {}
local _isAuto = true
local _talkIndices = {}
local _pauseIndices = {}
local _currentTalkIndex = 0
local _pendingEvents

local function _triggerEvent(textEvent)
    if textEvent.sound ~= nil then
        game.audio.playSound(textEvent.sound)
    end
    if textEvent.script ~= nil then
        local scriptInit = dofile(textEvent.script)
        if type(scriptInit) == 'function' then
            scriptInit(textEvent.variable)
        end
    end
end

local function _tryTriggerEvents()
    if type(_pendingEvents) ~= 'table' then
        return
    end
    local count = #_pendingEvents
    for i=1, count do
        _triggerEvent(_pendingEvents[i])
    end
end

local function _tryParseChunk(str)
    if game.string.sub(str, 1, 1) ~= '<' then
        return false
    end
    local delimiter = string.match(str, '<(.-)=')
    if delimiter == nil then
        return false
    end
    local callback = _callbacks[delimiter]
    if callback == nil then
        return false
    end
    local variable = string.match(str, '=(.-)>')
    callback(variable)
    return true
end

local function _getProcessedChunk(chunk)
    local function replace(s)
        return ''
    end
    for _, ignore in ipairs(_ignore) do
        chunk = chunk.gsub(chunk, ignore, replace)
    end
    return chunk
end

local function _tryPause(str)
    if game.string.sub(str, 1, 1) ~= '<' then
        return false
    end
    local delimiter = string.match(str, '<(.-)=')
    if delimiter ~= 'pause' then
        return false
    end
    local variable = string.match(str, '=(.-)>')
    local time = tonumber(variable)
    if time ~= nil then
        _talkTimer = _talkTimer - time
    end
    return true
end

local function _addWordToIndices(previous, current)
    local limit = math.random(3, 5)
    local count = current - previous
    local syllables = 1
    while limit < count do
        count = count - limit
        limit = math.random(3, 5)
        syllables = syllables + 1
    end
    local indicesPerSyllable = math.floor((current - previous) / syllables)
    if indicesPerSyllable < 1 then
        indicesPerSyllable = 1
    end
    for i=1, syllables do
        local index = previous + (i * indicesPerSyllable)
        if index > current then
            index = current
        end
        _talkIndices[index] = 1
    end
end

local function _isEndOfSentence(previous)
    return previous == '.' or previous == '?' or previous == '!' or previous == ';'
end

local function _populateTalkingIndices(chunk)
    _currentTalkIndex = 0
    local target = ' ' --TODO: targets for other languages that don't use space, or maybe just use the letterCount fallback

    _talkIndices = {
        [1] = 1,
    }
    _pauseIndices = {}
    local previousIndex = 0
    local i = 0
    local previous = ''
    local processedChunk = _getProcessedChunk(chunk)
    for _, code in game.string.codes(processedChunk) do
        i = i + 1
        local c = game.string.char(code)
        if c == target then
            if _isEndOfSentence(previous) then
                _pauseIndices[i] = 1
            end
            _addWordToIndices(previousIndex, i)
            previousIndex = i
        end
        previous = c
    end
    _addWordToIndices(previousIndex, i)
end

local function _setVisibleCharacters(amount)
    if _text ~= nil then
        _text.setMaxVisibleCharacters(amount)
    end
    if _shadowText ~= nil then
        _shadowText.setMaxVisibleCharacters(amount)
    end
end

local function _setText(text)
    if _text ~= nil then
        _text.setText(text)
    end
    if _shadowText ~= nil then
        _shadowText.setText(text)
    end
end

local function _setProgressActive(isActive)
    if _progressIndicator ~= nil then
        if isActive then
            _progressIndicator.setColor(1.0, 1.0, 1.0, 1.0)
        else
            _progressIndicator.setColor(0, 0, 0, 0)
        end
    end
end

local function _getParsedTextLength()
    if _text == nil then
        return 0
    end
    return _text.getParsedTextLength()
end

local function _parseNextChunk()
    if #_currentChunks < 1 then
        _isWaiting = true
        if not _isAuto then
            _setProgressActive(true)
        end
        return 0
    end
    local chunk = table.remove(_currentChunks, 1)
    if _tryPause(chunk) then
        return 0
    end
    if _tryParseChunk(chunk) then
        return 1
    end
    _currentText = _currentText .. chunk
    _populateTalkingIndices(chunk)
    _setText(_currentText)
    _currentParsedLength = _getParsedTextLength()
    return 2
end

local function _tryGetNextChunk()
    while true do
        local chunkStatus = _parseNextChunk()
        if chunkStatus == 0 then
            return 0
        end
        if chunkStatus == 2 then
            return 1
        end
    end
end

local function _playTalkSound()
    local skip = game.data.getSetting('disableDialogueSounds')
    if skip == 1 then
        return
    end
    game.audio.playSound(_sound)
end

local function _iterateText(deltaTime)
    _talkTimer = _talkTimer + deltaTime
    if _talkTimer < 1.0 / 24.0 then
        return 0
    end
    _talkTimer = _talkTimer - (1.0 / 24.0)
    _currentTalkIndex = _currentTalkIndex + 1
    if _talkIndices[_currentTalkIndex] then
        _playTalkSound()
    end
    if _pauseIndices[_currentTalkIndex + 1] then
        _talkTimer = _talkTimer - 0.5
    end
    --get next chunk
    if _currentVisibleCharacters >= _currentParsedLength then
        if _tryGetNextChunk() == 0 then
            return 0
        end
    end
    --iterate characters
    _currentVisibleCharacters = _currentVisibleCharacters + 1
    _setVisibleCharacters(_currentVisibleCharacters)
    return 0
end

local function _iterateImmediate()
    while #_currentChunks > 0 do
        _parseNextChunk()
    end
    _setVisibleCharacters(-1)
    _isWaiting = true
    if not _isAuto then
        _setProgressActive(true)
    end
end

function dialogueText.init(target, chunk, isAuto)
    for k, _ in pairs(_callbacks) do
        local delimiter = '<' .. k .. '=.->'
        table.insert(_delimiters, delimiter)
    end
    _isAuto = isAuto
    _sound = chunk.sound
    _next = chunk.next
    _pendingEvents = chunk.events
    local translatedText = game.text.getText(chunk.key)
    _currentChunks = game.string.splitWithDelimiters(translatedText, _delimiters)
    local textObject = target.find('text')
    if textObject ~= nil then
        _text = textObject.getComponent('text')
    end
    local shadowObject = target.find('shadow')
    if shadowObject ~= nil then
        _shadowText = shadowObject.getComponent('text')
    end
    local progressObject = target.find('progress')
    if progressObject ~= nil then
        _progressIndicator = progressObject.getComponent('image')
    end
    _setVisibleCharacters(0)
end

function dialogueText.update()
    --waiting after text complete
    local deltaTime = game.timer.getDeltaTime()
    if _isWaiting then
        if _pendingProgress then
            _setProgressActive(false)
            _tryTriggerEvents()
            return _next
        else
            if _isAuto then
                _autoTimer = _autoTimer - deltaTime
                if _autoTimer <= 0 then
                    _setProgressActive(false)
                    _tryTriggerEvents()
                    return _next
                end
            end
            return 0
        end
    end
    --skip iterating if progressed
    if _pendingProgress then
        _pendingProgress = false
        _iterateImmediate()
        return 0
    end
    return _iterateText(deltaTime)
end

function dialogueText.destroy()
    _setProgressActive(false)
    _setVisibleCharacters(0)
    _setText('')
end

function dialogueText.progress()
    _pendingProgress = true
end

return dialogueText
