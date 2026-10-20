local audioManager = {}

local _activeSounds = {}

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
    local effectVolume = engine.settings.getSetting('effectVolume') * 0.01
    local overallVolume = engine.settings.getSetting('overallVolume') * 0.01
    local focusMultiplier = _getFocusMultiplier()
    return effectVolume * overallVolume * focusMultiplier
end

function audioManager.play(path, pitchOverride, ignoreTime)
    if type(path) ~= 'string' then
        return
    end
    local sound = engine.fileSystem.loadJson(path)
    if sound == nil then
        return
    end
    local clip = engine.fileSystem.loadSound(sound.clip)
    if clip == nil then
        return
    end
    clip = clip:clone()
    clip:setLooping(sound.loop)
    local pitch
    if type(pitchOverride) == 'number' then
        pitch = pitchOverride
    else
        local minPitch = sound.pitch - sound.variance
        local maxPitch = sound.pitch + sound.variance
        pitch = minPitch + ((maxPitch - minPitch) * math.random())
    end
    local source = engine.dofile('engine/sound.lua')
    source.init(clip)
    if ignoreTime ~= 'boolean' then
        ignoreTime = false
    end
    source.ignorePitchMultiplier = ignoreTime
    source.setVolume(sound.volume)
    source.setPitch(pitch)
    source.setVolumeMultiplier(_getVolumeMultiplier())
    source.setPitchMultiplier(engine.timer.getTimescale())
    source.play()
    table.insert(_activeSounds, source)
    return source
end

function audioManager.stop()
    for _, source in ipairs(_activeSounds) do
        source.stop()
        source.isActive = false
    end
    _activeSounds = {}
end

local function _updateSource(index, volume, pitch)
    local source = _activeSounds[index]
    source.checkCompletion()
    if not source.isActive then
        table.remove(_activeSounds, index)
        return
    end
    source.setVolumeMultiplier(volume)
    source.setPitchMultiplier(pitch)
end

function audioManager.update()
    local volume = _getVolumeMultiplier()
    local pitch = engine.timer.getTimescale()
    local count = #_activeSounds
    for i=count, 1, -1 do
        _updateSource(i, volume, pitch)
    end
end

return audioManager