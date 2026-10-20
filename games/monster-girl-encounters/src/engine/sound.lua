local sound = {
    ignorePitchMultiplier = false,
    isActive = true,
}

local _source
local _rawVolume = 1.0
local _rawPitch = 1.0
local _previousPitch = 1.0
local _pitchMultiplier = 1.0
local _volumeMultiplier = 1.0

local function _setVolume()
    _source:setVolume(_volumeMultiplier * _rawVolume)
end

local function _setPitch()
    local currentPitch = _pitchMultiplier * _rawPitch
    if currentPitch <= 0 then
        if _previousPitch > 0 then
            _source:pause()
        end
        _previousPitch = currentPitch
        return
    end
    _source:setPitch(currentPitch)
    if _previousPitch <= 0 then
        _source:play()
    end
    _previousPitch = currentPitch
end

function sound.init(source)
    _source = source
end

function sound.play()
    if sound.isActive then
        _source:play()
    end
end

function sound.stop()
    _source:stop()
    sound.isActive = false
end

function sound.pause()
    _source:pause()
end

function sound.setPitch(p)
    _rawPitch = p
    _setPitch()
end

function sound.getPitch()
    return _rawPitch
end

function sound.setVolume(v)
    _rawVolume = v
    _setVolume()
end

function sound.getVolume()
    return _rawVolume
end

function sound.isPlaying()
    return _source:isPlaying()
end

function sound.checkCompletion()
    if _source:isPlaying() then
        return
    end
    if _source:tell() ~= 0 then
        return
    end
    sound.isActive = false
end

function sound.setPitchMultiplier(multiplier)
    if sound.ignorePitchMultiplier then
        return
    end
    if _pitchMultiplier == multiplier then
        return
    end
    _pitchMultiplier = multiplier
    _setPitch()
end

function sound.setVolumeMultiplier(multiplier)
    if _volumeMultiplier == multiplier then
        return
    end
    _volumeMultiplier = multiplier
    _setVolume()
end

return sound