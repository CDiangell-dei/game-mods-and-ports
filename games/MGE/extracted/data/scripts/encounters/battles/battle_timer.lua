local battleTimer = {
    events = {},
    loops = 0,
}

local _index = 0
local _onComplete = nil
local _isWaiting = true

local function _setNextState()
    _index = _index + 1
    local state = battleTimer.events[_index]
    if state == nil then
        return false
    end
    battleTimer.loops = state.loops or 1
    if state.action ~= nil then
        state.action()
    end
    return true
end

local function _processCallback()
    if _onComplete == nil then
        return
    end
    local onComplete = _onComplete
    _onComplete = nil
    onComplete()
end

local function _tick()
    if _isWaiting then
        return
    end
    battleTimer.loops = battleTimer.loops - 1
    if battleTimer.loops > 0 then
        return
    end
    if _setNextState() then
        return
    end
    _processCallback()
end

local function _init()
    local ui = game.control.encounter.ui
    ui.subscribeOnAnimationComplete(_tick)
end

function battleTimer.setOnComplete(onComplete)
    _onComplete = onComplete
end

function battleTimer.init()
    _index = 0
    _isWaiting = false
    _setNextState()
end

function battleTimer.reset()
    _index = 0
end

function battleTimer.wait()
    _isWaiting = true
end

function battleTimer.resume()
    _isWaiting = false
end

_init()

return battleTimer
