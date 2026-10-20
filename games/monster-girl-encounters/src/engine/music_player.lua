local musicPlayer = {}

local _activeSource = nil
local _pendingPlays = {}
local _isPaused = false
local _updateFade = nil

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

function musicPlayer.play(path)
    if type(path) ~= 'string' then
        return
    end
    _isPaused = false
    local sound = engine.fileSystem.loadJson(path)
    if sound == nil then
        musicPlayer.stop()
        return
    end
    local clip = engine.fileSystem.loadSound(sound.clip)
    if clip == nil then
        musicPlayer.stop()
        return
    end
    table.insert(_pendingPlays, {
        isPlay = true,
        sound = sound,
        clip = clip,
    })
end

function musicPlayer.stop()
    table.insert(_pendingPlays, {
        isPlay = false,
    })
end

function musicPlayer.pause()
    if _isPaused then
        return
    end
    if _activeSource ~= nil then
        _activeSource.pause()
    end
    _isPaused = true
end

function musicPlayer.resume()
    if not _isPaused then
        return
    end
    _isPaused = false
    if _activeSource ~= nil then
        _activeSource.play()
    end
end

function musicPlayer.adjustPitch(pitch)
    if type(pitch) ~= 'number' then
        return
    end
    if _activeSource ~= nil then
        _activeSource.setPitch(pitch)
    end
end

local function _tryQueueNextFade()
    local count = #_pendingPlays
    if count == 0 then
        return
    end
    local play = table.remove(_pendingPlays, 1)
    if play.isPlay then
        local fader = engine.dofile('engine/cross_fader.lua')
        _activeSource = fader.init(play.sound, play.clip, _activeSource)
        _updateFade = fader.update
    else
        local fader = engine.dofile('engine/fade_out.lua')
        fader.init(_activeSource)
        _updateFade = fader.update
    end
end

function musicPlayer.update()
    if _updateFade ~= nil then
        if _updateFade(_isPaused) then
            return
        end
        _updateFade = nil
    end
    _tryQueueNextFade()
    if _activeSource ~= nil then
        local volumeMultiplier = _getVolumeMultiplier()
        _activeSource.setVolumeMultiplier(volumeMultiplier)
    end
end

return musicPlayer