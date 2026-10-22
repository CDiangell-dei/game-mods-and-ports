local _time = 0
local _currentTime = 0
local _start = {
    x = 0,
    y = 0
}
local _goal = {
    x = 0,
    y = 0
}
local _background

local function _update()
    local dt = game.timer.getDeltaTime()
    _currentTime = _currentTime + dt
    if _currentTime >= _time then
        _currentTime = _time
    end
    local x = ((_goal.x - _start.x) * (_currentTime / _time)) + _start.x
    local y = ((_goal.y - _start.y) * (_currentTime / _time)) + _start.y
    _background.setPosition(x, y)
    if _currentTime >= _time then
        game.events.unsubscribe('update', _update)
    end
end

local function _init(data)
    _background = game.object.getRoot().find('main/viewport/battle/background')
    if _background == nil then
        return
    end
    if data == nil then
        return
    end
    _time = data.duration or 0
    if data.start ~= nil then
       _start.x = data.start.x or 0
       _start.y = data.start.y or 0
    end
    if data.goal ~= nil then
        _goal.x = data.goal.x or 0
        _goal.y = data.goal.y or 0
    end
    if data.size ~= nil then
        local w = data.size.x or 1
        local h = data.size.y or 1
        _background.setSize(w, h)
    end
    if _time <= 0 then
        _background.setPosition(_goal.x, _goal.y)
        return
    end
    _background.setPosition(_start.x, _start.y)
    game.events.subscribe('update', _update)
end

return _init
