local fader = {}

local _steps = {
    [0] = game.data.loadSprite('data/sprites/dither/0.png'),
    [10] = game.data.loadSprite('data/sprites/dither/10.png'),
    [20] = game.data.loadSprite('data/sprites/dither/20.png'),
    [30] = game.data.loadSprite('data/sprites/dither/30.png'),
    [40] = game.data.loadSprite('data/sprites/dither/40.png'),
    [50] = game.data.loadSprite('data/sprites/dither/50.png'),
    [60] = game.data.loadSprite('data/sprites/dither/60.png'),
    [70] = game.data.loadSprite('data/sprites/dither/70.png'),
    [80] = game.data.loadSprite('data/sprites/dither/80.png'),
    [90] = game.data.loadSprite('data/sprites/dither/90.png'),
    [100] = game.data.loadSprite('data/sprites/dither/100.png'),
}
local _graphic
local _goal
local _time
local _activeSprite
local _callback = nil
local _alpha = 0
local _alphaPerSecond
local _ignoreTimescale = false
local _cancelled = true
local _delay = 0

local function _getCurrentSprite()
    for i=100, 0, -10 do
        if _alpha >= i then
            return _steps[i]
        end
    end
    return _steps[0]
end

local function _setDither()
    local fadeSprite = _getCurrentSprite()
    if fadeSprite ~= _activeSprite then
        _graphic.setSprite(fadeSprite)
        _activeSprite = fadeSprite
    end
end

local function _update()
    if _graphic.object.isDestroyed() then
        fader.cancel()
        game.events.unsubscribe('update', _update)
        return
    end
    if _cancelled then
        return
    end
    if _delay > 0 then
        _delay = _delay - 1
        return
    end
    local deltaTime
    if _ignoreTimescale then
        deltaTime = game.timer.getUnscaledDeltaTime()
    else
        deltaTime = game.timer.getDeltaTime()
    end
    _time = _time - deltaTime
    _alpha = _alpha + (_alphaPerSecond * deltaTime)
    if _time <= 0 then
        _alpha = _goal
        _setDither()
        local callback = _callback
        fader.cancel()
        if callback ~= nil then
            callback()
        end
        return
    else
        _setDither()
    end
end


function fader.fadeTo(goal, duration, callback)
    _delay = 1
    _cancelled = false
    _goal = goal
    _time = duration
    _callback = callback
    if duration <= 0 then
        _alphaPerSecond = 0
    else
        _alphaPerSecond = (goal - _alpha) / duration
    end
end

function fader.getAlpha()
    return _alpha
end

function fader.cancel()
    _callback = nil
    _cancelled = true
end

function fader.isFading()
    return not _cancelled
end

function fader.init(graphic, initialAlpha, ignoreTimescale)
    _alpha = initialAlpha or 0
    _ignoreTimescale = ignoreTimescale or false
    _graphic = graphic
    game.events.subscribe('update', _update)
end

return fader