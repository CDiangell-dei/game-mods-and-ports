local pumpOrb = {}

local _floatTime = 1.0
local _time = 0
local _orbs = {}

local function _destroyOrbs()
    for _, orb in ipairs(_orbs) do
        orb.object.destroy()
    end
    _orbs = {}
end

local function _updateOrb(orb, progress)
    local y = ((orb.goalY - orb.startY) * progress) + orb.startY + 4
    orb.object.setPosition(orb.x, y)
    orb.image.setColor(1, 1.0 - (progress * 0.5), 1.0 - (progress * 0.5), 1.0 - progress)
end

local function _update()
    local dt = game.timer.getDeltaTime()
    _time = _time + dt
    if _time > _floatTime then
        _destroyOrbs()
        game.events.unsubscribe('update', _update)
        return
    end
    local progress = _time / _floatTime
    for _, orb in ipairs(_orbs) do
        _updateOrb(orb, progress)
    end
end

local function _spawnOrb(x, y)
    local orb = {}
    local parent = game.object.getRoot()
    local object = game.object.instantiate('data/scenes/orb.json', parent)
    local image = object.getComponent('image')
    local randomX = math.random(x, x + 32 - 8)
    local goalY = y - math.random(16, 32)
    object.setPosition(randomX, y)
    orb.object = object
    orb.image = image
    orb.x = randomX
    orb.startY = y
    orb.goalY = goalY
    table.insert(_orbs, orb)
end

function pumpOrb.init(x, y)
    local count = math.random(1, 4)
    for _=1, count do
        _spawnOrb(x, y)
    end
    game.events.subscribe('update', _update)
end

return pumpOrb
