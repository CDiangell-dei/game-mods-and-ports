local particleSource = {}

local _isDestroyed = false
local _sources = {}
local _initialSpawn = nil

function particleSource.populateFromData(data)
    if type(data) ~= 'table' then
        return
    end
    if data.duration == nil and data.burstCount == nil then
        return
    end
    if _initialSpawn == nil then
        _initialSpawn = {}
    end
    for k, v in pairs(data) do
        _initialSpawn[k] = v
    end
end

function particleSource.start()
    if _initialSpawn ~= nil then
        particleSource.spawn(_initialSpawn)
        _initialSpawn = nil
    end
end

function particleSource.update()
    local count = #_sources
    local dt = engine.timer.getDeltaTime()
    for i=count, 1, -1 do
        local isAlive = _sources[i].update(dt)
        if not isAlive then
            table.remove(_sources, i)
        end
    end
end

function particleSource.onDestroy()
    _isDestroyed = true
    _sources = nil
end

function particleSource.spawn(data)
    if _isDestroyed then
        return
    end
    if type(data) ~= 'table' then
        engine.debug.logError('Invalid data supplied to particleSource.')
        return
    end
    local source = engine.dofile('engine/components/particle_spawner.lua')
    source.init(particleSource.object, data)
    table.insert(_sources, source)
end

function particleSource.anyParticlesAlive()
    if _sources == nil then
        return false
    end
    return #_sources > 0
end

function particleSource.stop()
    local count = #_sources
    for i=count, 1, -1 do
        _sources[i].stop()
    end
end

return particleSource