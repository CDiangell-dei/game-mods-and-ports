local tween = {}

local _object
local _activePositionTween = nil
local _activeSizeTween = nil
local _tweens = {
    easeOut = 'data/scripts/ui/tween_easeOut.lua',
    easeOutQuint = 'data/scripts/ui/tween_easeOut_quint.lua',
    easeInQuint = 'data/scripts/ui/tween_easeIn_quint.lua',
    linear = 'data/scripts/ui/tween_linear.lua',
}

local function _getTween(tweenType)
    local ease
    if tweenType == nil or _tweens[tweenType] == nil then
        ease = _tweens.easeOut
    else
        ease = _tweens[tweenType]
    end
    return dofile(ease)
end

function tween.init(object)
    _object = object
end

function tween.tweenPosition(goalX, goalY, duration, callback, tweenType)
    if _activePositionTween ~= nil then
        _activePositionTween.cancel()
    end
    local ease = _getTween(tweenType)
    local x, y = _object.getPosition()
    ease.init(x, y, _object.setPosition)
    ease.tween(goalX, goalY, duration, callback)
    _activePositionTween = ease
end

function tween.tweenPositionRelative(goalX, goalY, duration, callback, tweenType)
    if _activePositionTween ~= nil then
        _activePositionTween.cancel()
    end
    local ease = _getTween(tweenType)
    local x, y = _object.getPosition()
    ease.init(x, y, _object.setPosition)
    ease.tween(x + goalX, y + goalY, duration, callback)
    _activePositionTween = ease
end

function tween.tweenSize(goalX, goalY, duration, callback, tweenType)
    if _activeSizeTween ~= nil then
        _activeSizeTween.cancel()
    end
    local ease = _getTween(tweenType)
    local x, y = _object.getSize()
    ease.init(x, y, _object.setSize)
    ease.tween(goalX, goalY, duration, callback)
    _activeSizeTween = ease
end

return tween