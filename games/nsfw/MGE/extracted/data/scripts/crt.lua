local crt = {}

local _shader
local _strength = 100
local _filmGrain = 1
local _aberration = 1
local _scale = 2.0
local _timePerNoiseChange = 1.0 / 6.0
local _time = 0

local function _updateAberration()
    local aberration = game.data.getSetting('chromaticAberration')
    if aberration == _aberration then
        return
    end
    _aberration = aberration
    if _aberration == 1 then
        _shader:send('chromatic_aberration', 1.0)
    else
        _shader:send('chromatic_aberration', 0)
    end
end

local function _updateGrain()
    local grain = game.data.getSetting('filmGrain')
    if grain == _filmGrain then
        return
    end
    _filmGrain = grain
    if _filmGrain == 1 then
        _shader:send('noise', 0.011)
    else
        _shader:send('noise', 0)
    end
end

local function _updateStrengthAndScale()
    local strength = game.data.getSetting('crtStrength')
    local scale = game.display.getRenderScale()
    if strength == _strength and _scale == scale then
        return
    end
    _scale = scale
    _strength = strength
    _shader:send('scale', _scale)
    if _scale < 2.0 then
        _shader:send('strength', 0)
        return
    end
    local amount = math.min(_strength, 100)
    amount = math.max(_strength, 0)
    _shader:send('strength', amount / 100.0)
end

local function _update()
    _updateAberration()
    _updateGrain()
    _updateStrengthAndScale()
    _time = _time + game.timer.getUnscaledDeltaTime()
    if _time < _timePerNoiseChange then
        return
    end
    _time = _time - _timePerNoiseChange
    _shader:send('time', game.timer.getUnscaledTime())
end

function crt.init(shader)
    _shader = shader
    game.events.subscribe('update', _update)
end

return crt
