local crossFader = {}

local _fadeTime = 0.5
local _time = 0
local _delay = 1
local _wasPaused = false
local _activeSource
local _previousSource

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

function crossFader.update(isPaused)
    if _delay > 0 then
        _delay = _delay - 1
        return true
    end
    if isPaused then
        if not _wasPaused then
            if _previousSource ~= nil then
                _previousSource.pause()
            end
            _wasPaused = true
        end
        return true
    end
    if _wasPaused then
        if _previousSource ~= nil then
            _previousSource.play()
        end
        _wasPaused = false
    end
    _time = _time + engine.timer.getUnscaledDeltaTime()
    if _time > _fadeTime then
        _time = _fadeTime
    end
    local progress = _time / _fadeTime
    local volumeMultiplier = _getVolumeMultiplier()
    if _previousSource ~= nil then
        _previousSource.setVolumeMultiplier(volumeMultiplier * (1.0 - progress))
    end
    if _activeSource ~= nil then
        _activeSource.setVolumeMultiplier(volumeMultiplier * progress)
    end
    if _time < _fadeTime then
        return true
    end
    if _previousSource ~= nil then
        _previousSource.stop()
    end
    return false
end

function crossFader.init(sound, clip, previousSource)
    _previousSource = previousSource
    clip = clip:clone()
    clip:setLooping(sound.loop)
    local minPitch = sound.pitch - sound.variance
    local maxPitch = sound.pitch + sound.variance
    local pitch = minPitch + ((maxPitch - minPitch) * math.random())
    local source = engine.dofile('engine/sound.lua')
    source.init(clip)
    source.ignorePitchMultiplier = true
    source.setVolume(sound.volume)
    source.setVolumeMultiplier(0)
    source.setPitch(pitch)
    source.play()
    _activeSource = source
    return source
end

return crossFader