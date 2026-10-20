local eventHandler = {}

--EVENT HANDLING
local _eventCallbacks = {}
local _pendings = {}

local function _addSubscriber(type, action)
    local typeCallback = _eventCallbacks[type]
    if typeCallback == nil then
        typeCallback = {}
        _eventCallbacks[type] = typeCallback
    end
	typeCallback[action] = action
end

local function _removeSubscriber(type, action)
    local typeCallback = _eventCallbacks[type]
    if typeCallback == nil then
        return
    end
	typeCallback[action] = nil
end

local function _processPendings()
    while #_pendings > 0 do
        local v = table.remove(_pendings, 1)
        if v.addType == 1 then
            _removeSubscriber(v.type, v.action)
        else
            _addSubscriber(v.type, v.action)
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

function eventHandler.subscribe(eventType, action)
    if eventType == nil then
        engine.debug.logError('Nil type for event_handler subscribe.')
        return
    end
    if type(action) ~= 'function' then
        engine.debug.logError('Invalid type supplied as callback to event_handler subscribe.')
        return
    end
    local pending = {
        addType = 3,
        type = eventType,
        action = action,
    }
    table.insert(_pendings, pending)
end

function eventHandler.unsubscribe(eventType, action)
    if eventType == nil then
        engine.debug.logError('Nil type for event_handler unsubscribe.')
        return
    end
    if type(action) ~= 'function' then
        engine.debug.logError('Invalid type supplied as callback to event_handler unsubscribe.')
        return
    end
    local pending = {
        addType = 1,
        type = eventType,
        action = action,
    }
    table.insert(_pendings, pending)
end

function eventHandler.invoke(eventType, ...)
    if eventType == nil then
        engine.debug.logError('Nil type for event_handler invoke.')
        return
    end
	_processPendings()
	local typeCallback = _eventCallbacks[eventType]
	if typeCallback == nil then
		return
	end
	for _, v in pairs(typeCallback) do
        _pCall(v, ...)
	end
end

function eventHandler.clear()
    _pendings = {}
    _eventCallbacks = {}
end

return eventHandler