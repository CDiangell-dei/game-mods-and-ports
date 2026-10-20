local eventSpawner = {}

local _data = require('data/scripts/data.lua')
local _spawnAreas = {
    {
        x = -91,
        y = 0,
        width = 59,
        height = 508,
    },
    {
        x = 410,
        y = 0,
        width = 106,
        height = 508,
    }
}
local _events = {
    {
        buff = 'buff3',
        intro = 'data/animations/gnome/intro/data.json',
        idle = 'data/animations/gnome/idle/data.json',
    },
    {
        buff = 'buff3',
        intro = 'data/animations/salamander/intro/data.json',
        idle = 'data/animations/salamander/idle/data.json',
    },
    {
        buff = 'buff3',
        intro = 'data/animations/sylph/intro/data.json',
        idle = 'data/animations/sylph/idle/data.json',
    },
    {
        buff = 'buff3',
        intro = 'data/animations/undine/intro/data.json',
        idle = 'data/animations/undine/idle/data.json',
    },
}
local _startTimer = 2.0
local _endTimer = 22.0
local _minSpawnTime
local _maxSpawnTime
local _uniqueId = 0
local _spawnTimer
local _time
local _activeEvents = {}
local _parent

local function _refreshSpawnTimer()
    local percentage = math.random()
    _spawnTimer = ((_maxSpawnTime - _minSpawnTime) * percentage) + _minSpawnTime
end

local function _getRandomEvent()
    local count = #_events
    if count < 1 then
        return nil
    end
    local index = math.random(count)
    return table.remove(_events, index)
end

local function _getRandomPosition()
    local index = math.random(1, #_spawnAreas)
    local area = _spawnAreas[index]
    local width = area.width * math.random()
    local height = area.height * math.random()
    local x = math.floor(area.x + width)
    local y = math.floor(area.y + height)
    return x, y
end

local function _popAtIndex(i)
    local e = table.remove(_activeEvents, i)
    eventSpawner._destroyEventObject(e)
    local function addBuff()
        game.control.buffs.add(e.buff)
    end
    game.timer.queue(0.5, addBuff)
end

local function _popEvent(object)
    local count = #_activeEvents
    for i=count, 1, -1 do
        local e = _activeEvents[i]
        if e.object == object then
            _popAtIndex(i)
            return
        end
    end
end

local function _spawnBuffEvent()
    local randomEvent = _getRandomEvent()
    print('try spawn event')
    if randomEvent == nil then
        return
    end
    print('spawn event: ' .. tostring(randomEvent.intro))
    local object = eventSpawner._spawnEventObjectAtRandomLocation(randomEvent)
    local function selectEvent()
        --TODO: Play sounds?
        _popEvent(object)
    end
    if object ~= nil then
        local button = object.find('sprite').getComponent('button')
        if button ~= nil then
            button.onClick.subscribe(selectEvent)
        end
    end
    local buff = _data.buffs[randomEvent.buff]
    table.insert(_activeEvents, {
        object = object,
        buff = buff,
        timer = 5.0,
    })
end

function eventSpawner._spawnEventObjectAtRandomLocation(event)
    local x, y = _getRandomPosition()
    local object = game.object.instantiate('data/scenes/random_event.json', _parent)
    _uniqueId = _uniqueId + 1
    object.name = 'randomEvent_' .. tostring(_uniqueId)
    object.setPosition(x, y)
    local sprite = object.find('sprite')
    local animator = sprite.getComponent('animator')
    local function startIdle()
        animator.onCompletion.unsubscribe(startIdle)
        game.object.setVisual(sprite, event.idle)
    end
    animator.onCompletion.subscribe(startIdle)
    game.object.setVisual(sprite, event.intro)
    local translator = dofile('data/scripts/ui/position_translator.lua')
    translator.init(object)
    local translateDown
    local function translateUp()
        if object.isDestroyed() then
            return
        end
        y = y + 5
        translator.moveTo(x, y, 1.0)
        game.timer.queue(1.0, translateDown)
    end
    translateDown = function()
        if object.isDestroyed() then
            return
        end
        y = y - 5
        translator.moveTo(x, y, 1.0)
        game.timer.queue(1.0, translateUp)
    end
    translateUp()
    local dither = dofile('data/scripts/ui/dither_fader.lua')
    dither.init(object.getComponent('mask'), 0, false)
    dither.fadeTo(100, 0.5, nil)
    return object
end

function eventSpawner._destroyEventObject(activeEvent)
    if activeEvent.object == nil then
        return
    end
    local dither = dofile('data/scripts/ui/dither_fader.lua')
    dither.init(activeEvent.object.getComponent('mask'), 100, false)
    dither.fadeTo(0, 0.5, activeEvent.object.destroy)
end

function eventSpawner.init(parent)
    _parent = parent
    _time = 0
    _spawnTimer = 0
    _maxSpawnTime = _endTimer / #_events
    _minSpawnTime = _maxSpawnTime * 0.8
    _refreshSpawnTimer()
end

function eventSpawner.destroy()
    for _, e in ipairs(_activeEvents) do
        eventSpawner._destroyEventObject(e)
    end
    _activeEvents = {}
    _refreshSpawnTimer()
end

function eventSpawner.update(deltaTime)
    _time = _time + deltaTime
    if _time < _startTimer then
        return
    end
    local count = #_activeEvents
    for i=count, 1, -1 do
        local e =  _activeEvents[i]
        e.timer = e.timer - deltaTime
        if e.timer <= 0 then
            eventSpawner._destroyEventObject(e)
            table.remove(_activeEvents, i)
        end
    end
    if _time >= _endTimer then
        return
    end
    _spawnTimer = _spawnTimer - deltaTime
    if _spawnTimer > 0 then
        return
    end
    _spawnBuffEvent()
    _refreshSpawnTimer()
end

function eventSpawner.pop()
    local count = #_activeEvents
    if count < 1 then
        return
    end
    _popAtIndex(1)
end

return eventSpawner