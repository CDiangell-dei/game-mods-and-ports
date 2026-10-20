local gnome = {
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
local _sparkleColor = {
    r = 1.0,
    g = 0.933,
    b = 0.533,
    a = 1.0
}

local function _receiveBlessing()
    local data = require('data/scripts/data.lua')
    local buff = data.buffs['gnome']
    game.control.buffs.add(buff)
    dofile('data/scripts/general/sparkle_effect.lua')
    game.timer.queue(1.0, gnome.ui.completeEncounter)
end

function gnome.init()
    gnome.ui.init()
    game.audio.playMusic('data/sounds/ambient1.json')
    gnome.ui.setBackground('data/sprites/encounters/gnome_bg.png')
    gnome.ui.setSprite('data/sprites/dither/0.png')
    gnome.ui.spawnDialogue('data/dialogue/gnome/1.json', _receiveBlessing)
end

function gnome.update(dt)
    _timer = _timer + dt
    if _timer < 0.1 then
        return
    end
    _timer = _timer - 0.1
    _effectSpawner.spawn('sparkle', _sparkleRange, _sparkleColor)
end

function gnome.onDestroy()
    gnome.ui.destroy()
end

return gnome
