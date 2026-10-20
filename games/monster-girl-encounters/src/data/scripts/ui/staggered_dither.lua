local staggeredDither = {
    transitionTime = 0.3,
}

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
local _onComplete = nil
local _activeDithers = {}
local _fadeTime = 0.2
local _hasExecuted = false
local _delay = 0

local function _setDither(graphic, alpha)
    for i=100, 0, -10 do
        if alpha >= i then
            graphic.setSprite(_steps[i])
            return
        end
    end
    graphic.setSprite(_steps[0])
end

local function _iterateDither(i, deltaTime)
    local dither = _activeDithers[i]
    if dither.delay > 0 then
        dither.delay = dither.delay - deltaTime
        if dither.delay > 0 then
            return
        end
    end
    dither.time = dither.time + deltaTime
    local progress = dither.time / _fadeTime
    if dither.fadeIn then
        _setDither(dither.graphic, progress * 100)
    else
        _setDither(dither.graphic, (1.0 - progress) * 100)
    end
    if dither.time >= _fadeTime then
        table.remove(_activeDithers, i)
    end
end

local function _update()
    if _delay > 0 then
        _delay = _delay - 1
        return
    end
    local deltaTime = game.timer.getUnscaledDeltaTime()
    local count = #_activeDithers
    for i=count, 1, -1 do
        _iterateDither(i, deltaTime)
    end
    if #_activeDithers < 1 then
        if _onComplete ~= nil then
            _onComplete()
        end
        staggeredDither.cancel()
    end
end

function staggeredDither.queueDitherIn(graphic, level)
    if _hasExecuted then
        return
    end
    table.insert(_activeDithers, {
        graphic = graphic,
        level = level,
        fadeIn = true,
    })
end

function staggeredDither.queueDitherOut(graphic, level)
    if _hasExecuted then
        return
    end
    table.insert(_activeDithers, {
        graphic = graphic,
        level = level,
        fadeIn = false,
    })
end

function staggeredDither.executeDither(onComplete)
    if _hasExecuted then
        game.debug.log('Execute dither can only be called once. Create a new staggeredDither.')
        return
    end
    _delay = 1
    _hasExecuted = true
    _onComplete = onComplete
    local maxLevel = 0
    local count = #_activeDithers
    for i=1, count do
        local dither = _activeDithers[i]
        if dither.level > maxLevel then
            maxLevel = dither.level
        end
    end
    local timePerLevel
    if maxLevel <= 0 then
        timePerLevel = 0
    else
        timePerLevel = staggeredDither.transitionTime / maxLevel
    end
    for i=1, count do
        local dither = _activeDithers[i]
        dither.delay = timePerLevel * dither.level
        dither.time = 0
        if dither.fadeIn then
            _setDither(dither.graphic, 0)
        else
            _setDither(dither.graphic, 100)
        end
    end
    game.events.subscribe('update', _update)
end

function staggeredDither.cancel()
    _activeDithers = nil
    game.events.unsubscribe('update', _update)
end

return staggeredDither