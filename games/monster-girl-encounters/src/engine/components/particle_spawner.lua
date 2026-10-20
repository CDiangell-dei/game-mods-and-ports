local spawner = {
    sprite = nil,
    parent = nil,
    minPosition = { x = 0, y = 0 },
    maxPosition = { x = 0, y = 0 },
    fixedPositions = nil,
    minVelocity = { x = 0, y = 0 },
    maxVelocity = { x = 0, y = 0 },
    minAcceleration = { x = 0, y = 0 },
    maxAcceleration = { x = 0, y = 0 },
    minStartingSize = { x = 0, y = 0 },
    maxStartingSize = { x = 0, y = 0 },
    minEndingSize = { x = 0, y = 0 },
    maxEndingSize = { x = 0, y = 0 },
    minStartingColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
    maxStartingColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
    minEndingColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
    maxEndingColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
    minLifetime = 0,
    maxLifetime = 0,
}

local _activeParticles = {}
local _duration = 0
local _particleTimer = 0
local _fixedIndex = 0
local _timePerParticle = 999.0

local function _randomRange(min, max)
    return min + ((max - min) * math.random())
end

local function _randomVector2(min, max)
    local x = _randomRange(min.x, max.x)
    local y = _randomRange(min.y, max.y)
    return { x = x, y = y }
end

local function _randomColor(min, max)
    local r = _randomRange(min.r, max.r)
    local g = _randomRange(min.g, max.g)
    local b = _randomRange(min.b, max.b)
    local a = _randomRange(min.a, max.a)
    return { r = r, g = g, b = b, a = a }
end

local function _getParticle()
    local particleObject = engine.objectManager.new(spawner.parent)
    particleObject.addComponent('image')
    particleObject.addComponent('animator')
    engine.objectManager.setVisual(particleObject, spawner.sprite)
    local particleScript = engine.dofile('engine/components/particle.lua')
    particleScript.source = particleObject
    return particleScript
end

local function _spawn()
    local position
    if spawner.fixedPositions == nil then
        position = _randomVector2(spawner.minPosition, spawner.maxPosition)
    else
        _fixedIndex = _fixedIndex + 1
        if _fixedIndex > #spawner.fixedPositions then
            _fixedIndex = 1
        end
        local fixedPosition = spawner.fixedPositions[_fixedIndex]
        if fixedPosition == nil then
            fixedPosition = {
                x = 0,
                y = 0,
            }
        end
        position = {
            x = fixedPosition.x,
            y = fixedPosition.y,
        }
    end
    local velocity = _randomVector2(spawner.minVelocity, spawner.maxVelocity)
    local acceleration = _randomVector2(spawner.minAcceleration, spawner.maxAcceleration)
    local startColor = _randomColor(spawner.minStartingColor, spawner.maxStartingColor)
    local endColor = _randomColor(spawner.minEndingColor, spawner.maxEndingColor)
    local startSize = _randomVector2(spawner.minStartingSize, spawner.maxStartingSize)
    local endSize = _randomVector2(spawner.minEndingSize, spawner.maxEndingSize)
    local lifetime = _randomRange(spawner.minLifetime, spawner.maxLifetime)
    local particle = _getParticle()
    particle.init(position, velocity, acceleration, startColor, endColor, lifetime, startSize, endSize)
    return particle
end

local function _setVector2(source, target)
    if type(source) ~= 'table' then
        target.x = 0
        target.y = 0
        return
    end
    if type(source.x) ~= 'number' then
        source.x = 0
    end
    if type(source.y) ~= 'number' then
        source.y = 0
    end
    target.x = source.x
    target.y = source.y
end

local function _setColor(source, target)
    if type(source) ~= 'string' then
        target.r = 1.0
        target.g = 1.0
        target.b = 1.0
        target.a = 1.0
        return
    end
    target.r, target.g, target.b, target.a = engine.graphics.hexToColor(source)
end

local function _populateSpawner(data)
    if data.fixedPositions == nil then
        _setVector2(data.minPosition, spawner.minPosition)
        _setVector2(data.maxPosition, spawner.maxPosition)
    else
        spawner.fixedPositions = {}
        for i=1, #data.fixedPositions do
            local v = {}
            spawner.fixedPositions[i] = v
            _setVector2(data.fixedPositions[i], v)
        end
    end
    _setVector2(data.minVelocity, spawner.minVelocity)
    _setVector2(data.maxVelocity, spawner.maxVelocity)
    _setVector2(data.minAcceleration, spawner.minAcceleration)
    _setVector2(data.maxAcceleration, spawner.maxAcceleration)
    _setVector2(data.minStartingSize, spawner.minStartingSize)
    _setVector2(data.maxStartingSize, spawner.maxStartingSize)
    _setVector2(data.minEndingSize, spawner.minEndingSize)
    _setVector2(data.maxEndingSize, spawner.maxEndingSize)
    _setColor(data.minStartingColor, spawner.minStartingColor)
    _setColor(data.maxStartingColor, spawner.maxStartingColor)
    _setColor(data.minEndingColor, spawner.minEndingColor)
    _setColor(data.maxEndingColor, spawner.maxEndingColor)
    if type(data.minLifetime) ~= 'number' then
        data.minLifetime = 0
    end
    if type(data.maxLifetime) ~= 'number' then
        data.maxLifetime = 0
    end
    spawner.minLifetime = data.minLifetime
    spawner.maxLifetime = data.maxLifetime
    if type(data.sprite) == 'string' then
        spawner.sprite = data.sprite
    end
end

function spawner.init(parent, data)
    spawner.parent = parent
    _populateSpawner(data)
    if type(data.duration) ~= 'number' then
        data.duration = 0
    end
    _duration = data.duration
    if type(data.particlesPerSecond) == 'number' and data.particlesPerSecond > 0 then
        _timePerParticle = 1.0 / data.particlesPerSecond
    end

    if type(data.burstCount) ~= 'number' then
        data.burstCount = 0
    end
    local _amount = data.burstCount
    for _=1, _amount do
        table.insert(_activeParticles, _spawn())
    end
end

function spawner.stop()
    _duration = 0
end

function spawner.update(dt)
    _duration = _duration - dt
    _particleTimer = _particleTimer + dt
    if _duration > 0 then
        while _particleTimer > _timePerParticle do
            _particleTimer = _particleTimer - _timePerParticle
            table.insert(_activeParticles, _spawn())
        end
    end
    local count = #_activeParticles
    for i=count, 1, -1 do
        if not _activeParticles[i].update(dt) then
            table.remove(_activeParticles, i)
        end
    end
    return #_activeParticles >= 1 or _duration > 0
end

return spawner