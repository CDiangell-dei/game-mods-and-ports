local fader = {}

local _goal = 1.0
local _start = 1.0
local _currentFade = 1.0
local _steps = 24
local _timer = 0
local _updateTickTimer = 0
local _totalTime = 0
local _textTimer = 0
local _loadingObject
local _loadingText
local _shader
local _onComplete = nil
local _blocker = nil
local _waitTime = 0
local _delay = 0

local function _updateTextColor()
    if _currentFade < 0 then
        _loadingText.setColor(1.0, 1.0, 1.0, -_currentFade)
    else
        _loadingText.setColor(0, 0, 0, _currentFade)
    end
end

local function _updateText(dt)
    _updateTextColor()
    _textTimer = _textTimer - dt
    if _textTimer > 0 then
        return
    end
    _textTimer = _textTimer + 0.3
    local characters = _loadingText.getMaxVisibleCharacters()
    characters = characters + 1
    if characters > 3 then
        characters = 1
    end
    _loadingText.setMaxVisibleCharacters(characters)
end

local function _updateShader()
    _shader:send('fade', _currentFade)
end

local function _updateFade(dt)
    if _timer <= 0 then
        return
    end
    _updateTickTimer = _updateTickTimer - dt
    if _updateTickTimer > 0 then
        return
    end
    local timePerStep = 1.0 / _steps
    _updateTickTimer = _updateTickTimer + timePerStep
    _timer = _timer - timePerStep
    if _timer < 0 then
        _timer = 0
    end
    local progress = 1.0 - (_timer / _totalTime)
    _currentFade = ((_goal - _start) * progress) + _start
    _updateShader()
    if _timer <= 0 then
        if _blocker ~= nil and _goal == 0 then
            _blocker.destroy()
            _blocker = nil
        end
        if _onComplete ~= nil then
            local callback = _onComplete
            _onComplete = nil
            local success, err = pcall(callback)
            if not success then
                game.debug.logError('Failed callback after fade.')
                if err ~= nil then
                    game.debug.logError(err)
                end
            end
        end
    end
end

local function _update()
    if _delay > 0 then
        _delay = _delay - 1
        return
    end
    local dt = game.timer.getUnscaledDeltaTime()
    _waitTime = _waitTime - dt
    if _waitTime <= 0 then
        _updateFade(dt)
    end
    --_updateText(dt)
end

local function _spawnBlocker()
    if _blocker ~= nil then
        return
    end
    _blocker = game.object.new()
    _blocker.setSize(game.config.canvasWidth, game.config.canvasHeight)
    _blocker.addComponent('button')
end

function fader.init(shader, initialValue)
    _shader = shader
    initialValue = initialValue or 1.0
    _goal = initialValue
    _start = initialValue
    _currentFade = initialValue
    --[[
    _loadingObject = game.object.new()
    _loadingObject.setPosition(game.config.canvasWidth - 55, game.config.canvasHeight - 40)
    _loadingObject.setSize(50, 20)
    _loadingText = _loadingObject.addComponent('text')
    _loadingText.setOverlay(true)
    _loadingText.setHorizontalAlignment('left')
    _loadingText.setVerticalAlignment('bottom')
    _loadingText.setMaxVisibleCharacters(1)
    _loadingText.setText('...')
    ]]--
    _updateShader()
    _spawnBlocker()
    --_updateText(0)
    game.events.subscribe('update', _update)
end

function fader.fadeToBlack(time, onComplete)
    _delay = 1
    _waitTime = 0
    _timer = time
    _totalTime = time
    _updateTickTimer = 1.0 / _steps
    _onComplete = onComplete
    _goal = -1.0
    _start = _currentFade
    _spawnBlocker()
end

function fader.fadeToWhite(time, onComplete)
    _delay = 1
    _waitTime = 0
    _timer = time
    _totalTime = time
    _updateTickTimer = 1.0 / _steps
    _onComplete = onComplete
    _goal = 1.0
    _start = _currentFade
    _spawnBlocker()
end

function fader.fadeIn(time, onComplete)
    _delay = 1
    _waitTime = 0.5
    _timer = time
    _totalTime = time
    _updateTickTimer = 1.0 / _steps
    _onComplete = onComplete
    _goal = 0.0
    _start = _currentFade
end

return fader
