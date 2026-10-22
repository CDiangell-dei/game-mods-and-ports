local tweenLinear = {}

local _x
local _y
local _onValueChange
local _startX
local _startY
local _goalX
local _goalY
local _duration
local _time
local _callback
local _isActive = false

local function _update()
    local deltaTime = game.timer.getDeltaTime()
    _time = _time + deltaTime
    if _time >= _duration then
        _x = _goalX
        _y = _goalY
        _onValueChange(_x, _y)
        game.events.unsubscribe('update', _update)
        if _callback ~= nil then
            _callback()
            _callback = nil
        end
        _isActive = false
    else
        local progress = _time / _duration
        _x = _startX + (progress * (_goalX - _startX))
        _y = _startY + (progress * (_goalY - _startY))
        _onValueChange(_x, _y)
    end
end

function tweenLinear.init(initialX, initialY, onValueChange)
    _onValueChange = onValueChange
    _x = initialX
    _y = initialY
end

function tweenLinear.tween(x, y, duration, callback)
    _startX = _x
    _startY = _y
    _goalX = x
    _goalY = y
    _duration = duration
    _time = 0
    _callback = callback
    if not _isActive then
        game.events.subscribe('update', _update)
    end
    _isActive = true
end

function tweenLinear.cancel()
    _callback = nil
    game.events.unsubscribe('update', _update)
    _isActive = false
end

return tweenLinear