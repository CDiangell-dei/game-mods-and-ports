local _object = game.object.instantiate('data/scenes/round_goal.json')
local _leftSource = _object.find('left').getComponent('particleSource')
local _rightSource = _object.find('right').getComponent('particleSource')
local _spawnData = {
    duration = 6,
    particlesPerSecond = 50,
    sprite = 'data/sprites/sparkle.png',
    minPosition = {
        x = 0,
        y = 0
    },
    maxPosition = {
        x = 142 - 8,
        y = 540 - 8
    },
    minVelocity = {
        x = 0,
        y = 0
    },
    maxVelocity = {
        x = 0,
        y = 0
    },
    minStartingSize = {
        x = 4,
        y = 4
    },
    maxStartingSize = {
        x = 4,
        y = 4
    },
    minEndingSize = {
        x = 8,
        y = 8
    },
    maxEndingSize = {
        x = 8,
        y = 8
    },
    minStartingColor = "FFFFFFFF",
    maxStartingColor = "FFFFFFFF",
    minEndingColor = "FFFFFF00",
    maxEndingColor = "FFFFFF00",
    minLifetime = 2,
    maxLifetime = 2,
}

local function _destroy()
    _object.destroy()
    _object = nil
end

local function _spawn()
   _leftSource.spawn(_spawnData)
   _rightSource.spawn(_spawnData)
   game.audio.playSound('data/sounds/general/sparkle.json')
   game.timer.queue(7.0, _destroy)
end

_spawn()
