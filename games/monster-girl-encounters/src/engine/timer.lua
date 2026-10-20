local timer = {}

local _routines = {}
local _pendingRoutines = {}
local _timescale = 1.0
local _deltaTime = 0
local _unscaledDeltaTime = 0
local _unscaledTime = 0
local _time = 0
local _pendingQueuedActions = {}
local _pendingScaledActions = {}
local _queuedActions = {}
local _scaledActions = {}
local _hasClearedCoroutines = false
local _hasClearedTimers = false

function timer.getTimescale()
	return _timescale
end

function timer.setTimescale(scale)
	if type(scale) ~= 'number' then
		return
	end
	_timescale = scale
end

function timer.getDeltaTime()
	return _deltaTime
end

function timer.getUnscaledDeltaTime()
	return _unscaledDeltaTime
end

function timer.getUnscaledTime()
	return _unscaledTime
end

function timer.getTime()
	return _time
end

function timer.startCoroutine(routine)
	if type(routine) ~= 'function' then
		engine.debug.logError('Invalid coroutine. It must be a function.')
		return nil
	end
	local co = coroutine.create(routine)
	table.insert(_pendingRoutines, co)
    return co
end

function timer.stopCoroutine(co)
	if co == nil then
		return
	end
	if _routines[co] ~= nil then
		_routines[co] = nil
		return
	end
	for i=1, #_pendingRoutines do
		local comparedCo = _pendingRoutines[i]
		if comparedCo == co then
			table.remove(_pendingRoutines, i)
			return
		end
	end
end

function timer.stopAllCoroutines()
	_routines = {}
	_pendingRoutines = {}
	_hasClearedCoroutines = true
end

function timer.queue(delay, action, ...)
	if type(delay) ~= 'number' or type(action) ~= 'function' then
		return
	end
	local queuedAction = {
		time = delay,
		callback = action,
		vars = ...,
	}
	table.insert(_pendingQueuedActions, queuedAction)
end

function timer.queueScaled(delay, action, ...)
	if type(delay) ~= 'number' or type(action) ~= 'function' then
		return
	end
	local queuedAction = {
		time = delay,
		callback = action,
		vars = ...,
	}
	table.insert(_pendingScaledActions, queuedAction)
end

function timer.clearQueuedActions()
	_queuedActions = {}
	_scaledActions = {}
	_pendingQueuedActions = {}
	_pendingScaledActions = {}
	_hasClearedTimers = true
end

local function _updateCoroutines()
	_hasClearedCoroutines = false
	for _, co in pairs(_routines) do
		local success, errOrAlive = pcall(coroutine.resume, co)
		if not success then
			engine.debug.logError('Failed coroutine in timer.')
			if errOrAlive ~= nil then
				engine.debug.logError(errOrAlive)
			end
			_routines[co] = nil
		end
		if _hasClearedCoroutines then
			return
		end
        if success and not errOrAlive then
            _routines[co] = nil
        end
	end
	while #_pendingRoutines > 0 do
		local co = table.remove(_pendingRoutines)
		_routines[co] = co
	end
end

local function _updateTimers(dt)
	_hasClearedTimers = false
	local count = #_queuedActions
	for i=count, 1, -1 do
		local queuedAction = _queuedActions[i]
		queuedAction.time = queuedAction.time - dt
		if queuedAction.time <= 0 then
			local success, err = pcall(queuedAction.callback, queuedAction.vars)
			if not success then
				engine.debug.logError('Failed queued callback from timer.')
				if err ~= nil then
					engine.debug.logError(err)
				end
			end
			if _hasClearedTimers then
				return
			end
			table.remove(_queuedActions, i)
		end
	end
	while #_pendingQueuedActions > 0 do
		local action = table.remove(_pendingQueuedActions)
		table.insert(_queuedActions, action)
	end
end

local function _updateScaledTimes(dt)
	_hasClearedTimers = false
	local count = #_scaledActions
	for i=count, 1, -1 do
		local queuedAction = _scaledActions[i]
		queuedAction.time = queuedAction.time - dt
		if queuedAction.time <= 0 then
			local success, err = pcall(queuedAction.callback, queuedAction.vars)
			if not success then
				engine.debug.logError('Failed queued callback from timer.')
				if err ~= nil then
					engine.debug.logError(err)
				end
			end
			if _hasClearedTimers then
				return
			end
			table.remove(_scaledActions, i)
		end
	end
	while #_pendingScaledActions > 0 do
		local action = table.remove(_pendingScaledActions)
		table.insert(_scaledActions, action)
	end
end

function timer.update(dt)
	_deltaTime = dt * _timescale
	_unscaledDeltaTime = dt
	_time = _time + _deltaTime
	_unscaledTime = _unscaledTime + _unscaledDeltaTime

	_updateCoroutines()
	_updateTimers(dt)
	_updateScaledTimes(_deltaTime)
end

return timer
