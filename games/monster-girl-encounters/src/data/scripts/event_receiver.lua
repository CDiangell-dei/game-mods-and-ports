local eventReceiver = {}

local _receivers = {}
local _pending = {}

local function _process()
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

function eventReceiver.subscribe(callback)
    if callback == nil then
        return
    end
    table.insert(_pending, {
        isAdd = true,
        callback = callback
    })
end

function eventReceiver.unsubscribe(callback)
    if callback == nil then
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
        callback(...)
    end
end

function eventReceiver.clear()
    _pending = {}
    _receivers = {}
end

return eventReceiver