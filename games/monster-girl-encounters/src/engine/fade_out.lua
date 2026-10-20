local fadeOut = {}

local _activeSource
local _fadeTime = 0.5
local _time = 0
local _delay = 1

local function _getFocusMultiplier()
    if engine.settings.getSetting('playSoundInBackground') == 1 then
        return 1.0
    end
    if engine.system.isFocused() then
        return 1.0
    end
    return 0
end

local function _getVolumeMultiplier()
    local effectVolume = engine.settings.getSetting('musicVolume') * 0.01
    local overallVolume = engine.settings.getSetting('overallVolume') * 0.01
    local focusMultiplier = _getFocusMultiplier()
    return effectVolume * overallVolume * focusMultiplier
end

function fadeOut.update(isPaused)
    if _delay > 0 then
        _delay = _delay - 1
        return true
    end
    if isPaused then
        return true
    end
    _time = _time + engine.timer.getUnscaledDeltaTime()
    if _time > _fadeTime then
        _time = _fadeTime
    end
    local progress = _time / _fadeTime
    local volumeMultiplier = _getVolumeMultiplier()
    _activeSource.setVolumeMultiplier(volumeMultiplier * (1.0 - progress))
    if _time < _fadeTime then
        return true
    end
    _activeSource.stop()
    return false
end

function fadeOut.init(previousSource)
    _activeSource = previousSource
end

return fadeOut