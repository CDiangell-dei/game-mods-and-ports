local animator = {
    type = 'Animator',
    onCompletion = engine.dofile('engine/event_receiver.lua'),
}

local _isDestroyed = false
local _animation = nil
local _speed = 1.0
local _time = 0
local _frameIndex = 0
local _target = nil
local _pendingAnimation = nil
local _delay = 1
local _stateChanged = false

local function _triggerEvent(animationEvent)
    if animationEvent.sound ~= nil then
        engine.audio.play(animationEvent.sound)
    end
    if animationEvent.script ~= nil then
        local scriptInit = engine.sandbox.dofile(animationEvent.script)
        if type(scriptInit) == 'function' then
            scriptInit(animationEvent.variable)
        end
    end
end

local function _tryTriggerEvents(animation)
    local events = animation.events[_frameIndex]
    if type(events) ~= 'table' then
        return
    end
    local count = #events
    for i=1, count do
        _triggerEvent(events[i])
    end
end

local function _tick(animation)
    _stateChanged = false
    if _target == nil or _time < 1.0 / animation.frameRate then
        return
    end
    _time = _time - (1.0 / animation.frameRate)
    _frameIndex = _frameIndex + 1
    if _frameIndex > #animation.activeFrames then
        if not animation.loop then
            animator.stop()
            animator.onCompletion.invoke()
            return
        end
        _frameIndex = 1
        animator.onCompletion.invoke()
    end
    if _stateChanged then
        return
    end
    _target.setSprite(animation.activeFrames[_frameIndex])
    _tryTriggerEvents(animation)
end

local function _update()
    if _delay > 0 then
        _delay = _delay - 1
        return
    end
    if _animation == nil then
        return
    end
    _time = _time + (engine.timer.getDeltaTime() * _speed)
    _tick(_animation)
end

local function _updateIgnoreScale()
    if _delay > 0 then
        _delay = _delay - 1
        return
    end
    if _animation == nil then
        return
    end
    _time = _time + (engine.timer.getUnscaledDeltaTime() * _speed)
    _tick(_animation)
end

function animator.populateFromData(data)
    if type(data.ignoreTimescale) == 'boolean' then
        animator.setIgnoreTimescale(data.ignoreTimescale)
    end
    if type(data.initialAnimation) == 'string' then
        _pendingAnimation = engine.fileSystem.loadAnimation(data.initialAnimation)
    end
end

function animator.start()
    _target = animator.object.getComponent('image')
    if _target == nil then
        _target = animator.object.getComponent('mask')
    end
    if _pendingAnimation then
        animator.play(_pendingAnimation)
        _pendingAnimation = nil
    end
end

animator.update = _update

function animator.onDestroy()
    _stateChanged = true
    _isDestroyed = true
    _animation = nil
    animator.onCompletion.clear()
end

function animator.isPlaying()
    if _isDestroyed or _target == nil then
        return false
    end
    return _animation ~= nil
end

function animator.play(animation)
    _stateChanged = true
    animator.stop()
    if _isDestroyed or _target == nil then
        return
    end
    if not engine.typeValidator.isAnimation(animation) then
        return
    end
    local framesType = type(animation.activeFrames)
    if framesType ~= 'table' then
        return
    end
    if #animation.activeFrames < 1 then
        return
    end
    _animation = animation
    _frameIndex = 0
    _time = 1.0 / animation.frameRate --next update, will go to actual frame 1
    _target.setSprite(animation.activeFrames[1])
end

function animator.stop()
    _stateChanged = true
    _animation = nil
end

function animator.setSpeed(speed)
    if type(speed) ~= 'number' then
        engine.debug.logError('Invalid setSpeed supplied to animator.')
        return
    end
    _speed = speed
end

function animator.getSpeed()
    return _speed
end

function animator.getLoopDuration()
    if _animation == nil or _animation.frameRate == nil or #_animation.activeFrames == 0 then
        return 0
    end
    return #_animation.activeFrames / _animation.frameRate
end

function animator.setIgnoreTimescale(ignoreScale)
    if type(ignoreScale) ~= 'boolean' then
        engine.debug.logError('Invalid setIgnoreTimescale supplied to animator.')
        return
    end
    if ignoreScale then
        animator.update = _updateIgnoreScale
    else
        animator.update = _update
    end
end

return animator