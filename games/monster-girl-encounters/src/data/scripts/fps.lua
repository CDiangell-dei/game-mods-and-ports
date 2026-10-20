local counter
local text

local frame = 0
local timer = 0

local function _spawnCounter()
    counter = engine.objectManager.new()
    counter.name = 'fps'
    counter.setPosition(15, 540 - 12 - 5)
    text = counter.addComponent('text')
    text.setOverlay(true)
end

local function _update()
    frame = frame + 1
    timer = timer + engine.timer.getUnscaledDeltaTime()
    if timer < 0.5 then
        return
    end
    local count = math.floor(frame / 0.5)
    timer = 0
    frame = 0
    text.setText(tostring(count))
end

_spawnCounter()
engine.events.subscribe('update', _update)