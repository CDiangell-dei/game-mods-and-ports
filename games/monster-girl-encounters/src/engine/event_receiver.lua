local eventReceiver = {}

local _receivers = {}
local _pending = {}

local  function _process()
    local count = #_pending
    for i=1, count do
        local pending = _pending[i]
        _pending[i] = nil
        if pending.isAdd then
            _receivers[pending.callback] = pending.callback
        else
            _receivers[pending.callback] = nil
        end
    end
end

local function _pCall(f, ...)
    local success, err = pcall(f, ...)
    if not success then
        engine.debug.logError('Failed to run event callback.')
        if err ~= nil then
            engine.debug.logError(err)
        end
    end
end

function eventReceiver.subscribe(callback)
    if type(callback) ~= 'function' then
        engine.debug.logError('Invalid type supplied as callback to event_receiver subscribe.')
        return
    end
    table.insert(_pending, {
        isAdd = true,
        callback = callback
    })
end

function eventReceiver.unsubscribe(callback)
    if type(callback) ~= 'function' then
        engine.debug.logError('Invalid type supplied as callback to event_receiver unsubscribe.')
        return
    end
    table.insert(_pending, {
        isAdd = false,
        callback = callback
    })
end

function eventReceiver.invoke(...)
    _process()
    for _, callback in pairs(_receivers) do
        _pCall(callback, ...)
    end
end

function eventReceiver.clear()
    _pending = {}
    _receivers = {}
end

return eventReceiver