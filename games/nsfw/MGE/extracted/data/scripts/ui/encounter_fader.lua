local encounterFader = {}

local _ditherFader
local _parent
local _fader
local _isActive = false
local _ignoreTimescale
local _operation = 0

local function _beginOperation()
    _operation = _operation + 1
    return _operation
end

local function _spawnDitherer(alpha)
    if _fader == nil then
        return false
    end
    if _ditherFader ~= nil then
        _ditherFader.cancel()
    end
    _ditherFader = dofile('data/scripts/ui/dither_fader.lua')
    _ditherFader.init(_fader.getComponent('mask'), alpha, _ignoreTimescale)
    return true
end

function encounterFader.init(parent, ignoreTimescale, onComplete)
    local operation = _beginOperation()
    _ignoreTimescale = ignoreTimescale
    _parent = parent
    _isActive = true
    _fader = game.object.instantiate('data/scenes/intro_transition.json', _parent)
    local animator = _fader.find('sprite').getComponent('animator')
    local function loadDefault()
        if operation ~= _operation or _fader == nil then
            return
        end
        animator.onCompletion.unsubscribe(loadDefault)
        local animation = game.data.loadAnimation('data/animations/transition/idle/data.json')
        animator.play(animation)
        if onComplete ~= nil then
            onComplete()
        end
    end
    animator.onCompletion.subscribe(loadDefault)
end

function encounterFader.prepareEncounterSelection(onComplete)
    local operation = _beginOperation()
    if _fader == nil then
        return
    end
    local animator = _fader.find('sprite').getComponent('animator')
    local function complete()
        if operation ~= _operation or _fader == nil then
            return
        end
        animator.onCompletion.unsubscribe(complete)
        local animation = game.data.loadAnimation('data/animations/transition/idle_map/data.json')
        animator.play(animation)
        onComplete()
    end
    local function enter()
        if operation ~= _operation or _fader == nil then
            return
        end
        animator.onCompletion.unsubscribe(enter)
        animator.onCompletion.subscribe(complete)
        local animation = game.data.loadAnimation('data/animations/transition/enter_map/data.json')
        animator.play(animation)
    end
    if animator.isPlaying() then
        animator.onCompletion.subscribe(enter)
    else
        enter()
    end
end

function encounterFader.transitionToEncounter(onComplete)
    local operation = _beginOperation()
    if _fader == nil then
        return
    end
    local animator = _fader.find('sprite').getComponent('animator')
    local function complete()
        if operation ~= _operation or _fader == nil then
            return
        end
        animator.onCompletion.unsubscribe(complete)
        onComplete()
    end
    local animation = game.data.loadAnimation('data/animations/transition/exit_map/data.json')
    animator.play(animation)
    animator.onCompletion.subscribe(complete)
end

function encounterFader.fadeToTransition(duration, callback)
    local operation = _beginOperation()
    if _isActive and _fader ~= nil then
        _fader.destroy()
    end
    _fader = game.object.instantiate('data/scenes/default_transition.json', _parent)
    _isActive = true
    _spawnDitherer(0)
    _ditherFader.fadeTo(100, duration, function()
        if operation == _operation and callback ~= nil then
            callback()
        end
    end)
end

function encounterFader.fadeOut(duration, callback, r, g, b)
    local operation = _beginOperation()
    if not _isActive then
        if _fader ~= nil then
            _fader.destroy()
        end
        _fader = game.object.instantiate('data/scenes/main_cover.json', _parent)
        _spawnDitherer()
        _isActive = true
    end
    r = r or 0
    g = g or 0
    b = b or 0
    _fader.find('sprite').getComponent('image').setColor(r, g, b, 1.0)
    _spawnDitherer(0)
    _ditherFader.fadeTo(100, duration, function()
        if operation == _operation and callback ~= nil then
            callback()
        end
    end)
end

function encounterFader.fadeIn(duration, callback)
    local operation = _beginOperation()
    if not _isActive then
        if callback ~= nil then
            callback()
        end
        return
    end
    local function onComplete()
        if operation ~= _operation then
            return
        end
        if _fader ~= nil then
            _fader.destroy()
            _fader = nil
        end
        _isActive = false
        if callback ~= nil then
            callback()
        end
    end
    if not _spawnDitherer(100) then
        _isActive = false
        if callback ~= nil then
            callback()
        end
        return
    end
    _ditherFader.fadeTo(0, duration, onComplete)
end

function encounterFader.cancel()
    _beginOperation()
    if _ditherFader ~= nil then
        _ditherFader.cancel()
    end
    _ditherFader = nil
end

return encounterFader