local salamander = {
    ui = dofile('data/scripts/ui/dialogue_encounter.lua'),
}

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
local _sparkleColors = {
    {
        r = 1.0,
        g = 1.0,
        b = 1.0,
        a = 1.0
    },
    {
        r = 0.7373,
        g = 0.4706,
        b = 0.4471,
        a = 1.0
    },
    {
        r = 0.8118,
        g = 0.7725,
        b = 0.4863,
        a = 1.0
    },
}
local _colorIndex = 0

local function _receiveBlessing()
    salamander.ui.fadeSprite('data/sprites/dither/0.png')
    local data = require('data/scripts/data.lua')
    local buff = data.buffs['salamander']
    game.control.buffs.add(buff)
    dofile('data/scripts/general/sparkle_effect.lua')
    game.timer.queue(1.0, salamander.ui.completeEncounter)
end

local function _spawnFairy()
    salamander.ui.fadeSprite('data/animations/salamander/data.json')
    salamander.ui.spawnDialogue('data/dialogue/salamander/2.json', _receiveBlessing)
end

function salamander.init()
    salamander.ui.init()
    game.audio.playMusic('data/sounds/lava.json')
    salamander.ui.setBackground('data/sprites/encounters/salamander_bg.png')
    salamander.ui.setSprite('data/sprites/dither/0.png')
    salamander.ui.spawnDialogue('data/dialogue/salamander/1.json', _spawnFairy)
end

function salamander.update(dt)
    _timer = _timer + dt
    if _timer < 0.1 then
        return
    end
    _timer = _timer - 0.1
    _colorIndex = _colorIndex + 1
    if _colorIndex > #_sparkleColors then
        _colorIndex = 1
    end
    _effectSpawner.spawn('sparkle', _sparkleRange, _sparkleColors[_colorIndex])
end

function salamander.onDestroy()
    salamander.ui.destroy()
end

return salamander
