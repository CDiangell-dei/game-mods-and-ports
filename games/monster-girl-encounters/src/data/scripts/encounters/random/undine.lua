local undine = {
    ui = dofile('data/scripts/ui/dialogue_encounter.lua'),
}

local _pendingPath = 0
local _effectSpawner = require('data/scripts/ui/effect_spawner.lua')
local _timer = 0
local _sparkleRange = {
    max = {
        x = 410-16,
        y = 410-16
    },
    min = {
        x = 0,
        y = 0
    }
}
local _sparkleColor = {
    r = 1.0,
    g = 1.0,
    b = 1.0,
    a = 1.0
}

local function _receiveBlessing()
    local data = require('data/scripts/data.lua')
    local buff = data.buffs['undine']
    game.control.buffs.add(buff)
    dofile('data/scripts/general/sparkle_effect.lua')
    game.timer.queue(1.0, undine.ui.completeEncounter)
end

local function _verifyCompletion()
    if _pendingPath == 1 then
        undine.ui.spawnDialogue('data/dialogue/undine/2a.json', _receiveBlessing)
    else
        game.control.ui.fadeToBlack()
        undine.ui.spawnDialogue('data/dialogue/undine/2b.json', _receiveBlessing)
    end
end

function undine.init()
    undine.ui.init()
    game.audio.playMusic('data/sounds/water_stream.json')
    undine.ui.setBackground('data/sprites/encounters/undine_bg.png')
    undine.ui.setSprite('data/sprites/dither/0.png')
    undine.ui.spawnDialogue('data/dialogue/undine/1.json', _verifyCompletion)
end

function undine.update(dt)
    _timer = _timer + dt
    if _timer < 0.1 then
        return
    end
    _timer = _timer - 0.1
    _effectSpawner.spawn('sparkle', _sparkleRange, _sparkleColor)
end

function undine.setPath(path)
    _pendingPath = path
end

function undine.onDestroy()
    undine.ui.destroy()
end

return undine
