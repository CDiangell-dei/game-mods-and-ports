local sylph = {
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
    g = 0.933,
    b = 0.533,
    a = 1.0
}

local function _receiveBlessing()
    sylph.ui.setSprite('data/sprites/dither/0.png')
    local data = require('data/scripts/data.lua')
    local buff = data.buffs['sylph']
    game.control.buffs.add(buff)
    dofile('data/scripts/general/sparkle_effect.lua')
    game.timer.queue(1.0, sylph.ui.completeEncounter)
end

local function _spawnFairy()
    sylph.ui.fadeSprite('data/animations/sylph/data.json')
    sylph.ui.spawnDialogue('data/dialogue/sylph/3.json', _receiveBlessing)
end

local function _verifyCompletion()
    if _pendingPath == 0 then
        sylph.ui.spawnDialogue('data/dialogue/sylph/2c.json', _spawnFairy)
        return
    end
    local gold = game.control.getGold()
    if gold <= 0 then
        sylph.ui.spawnDialogue('data/dialogue/sylph/2b.json', _spawnFairy)
        return
    end
    game.control.loseGold(1)
    game.audio.playSound('data/sounds/general/splash_small.json')
    sylph.ui.spawnDialogue('data/dialogue/sylph/2a.json', _spawnFairy)
end

function sylph.init()
    sylph.ui.init()
    game.audio.playMusic('data/sounds/enchanted_forest.json')
    sylph.ui.setBackground('data/sprites/encounters/sylph_bg.png')
    sylph.ui.setSprite('data/sprites/dither/0.png')
    sylph.ui.spawnDialogue('data/dialogue/sylph/1.json', _verifyCompletion)
end

function sylph.update(dt)
    _timer = _timer + dt
    if _timer < 0.1 then
        return
    end
    _timer = _timer - 0.1
    _effectSpawner.spawn('sparkle', _sparkleRange, _sparkleColor)
end

function sylph.setPath(path)
    _pendingPath = path
end

function sylph.onDestroy()
    sylph.ui.destroy()
end

return sylph
