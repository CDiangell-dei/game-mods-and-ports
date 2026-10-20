local positionTranslator = {}

local _object
local _xGoal
local _yGoal
local _time
local _x
local _y
local _xPerSecond
local _yPerSecond

local function _update()
    local deltaTime = game.timer.getUnscaledDeltaTime()
    _time = _time - deltaTime
    _x = _x + (_xPerSecond * deltaTime)
    _y = _y + (_yPerSecond * deltaTime)
    if _time <= 0 then
        _x = _xGoal
        _y = _yGoal
        game.events.unsubscribe('update', _update)
    end
    _object.setPosition(_x, _y)
end

function positionTranslator.init(object)
    _object = object
    _x, _y = object.getPosition()
end

function positionTranslator.moveTo(x, y, duration)
    _xGoal = x
    _yGoal = y
    _time = duration
    if duration <= 0 then
        _xPerSecond = 0
        _yPerSecond = 0
    else
        _xPerSecond = (_xGoal - _x) / duration
        _yPerSecond = (_yGoal - _y) / duration
    end
    game.events.subscribe('update', _update)
end

function positionTranslator.cancel()
    game.events.unsubscribe('update', _update)
end

return positionTranslator