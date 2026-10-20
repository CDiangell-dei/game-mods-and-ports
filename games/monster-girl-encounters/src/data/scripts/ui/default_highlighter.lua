local highlighter = {
    mouseoverSound = 'data/sounds/general/mouseover.json',
    mouseEnterColor = { r = 1.0, g = 1.0, b = 1.0, a  = 1.0 },
    defaultColor = { r = 0.9, g = 0.9, b = 0.9, a  = 1.0 },
    fadeTimer = 0.1,
}

local _hasInit = false
local _graphic = nil
local _mouseoverFader = nil

local function _mouseEnter()
    if highlighter.mouseoverSound ~= nil then
        game.audio.playSound(highlighter.mouseoverSound, nil, true)
    end
    if _graphic ~= nil then
        _graphic.setColor(highlighter.mouseEnterColor.r, highlighter.mouseEnterColor.g,
            highlighter.mouseEnterColor.b, highlighter.mouseEnterColor.a)
    end
    if _mouseoverFader ~= nil then
        _mouseoverFader.fadeTo(100, highlighter.fadeTimer, nil)
    end
end

local function _mouseExit()
    if _graphic ~= nil then
        _graphic.setColor(highlighter.defaultColor.r, highlighter.defaultColor.g,
            highlighter.defaultColor.b, highlighter.defaultColor.a)
    end
    if _mouseoverFader ~= nil then
        _mouseoverFader.fadeTo(0, highlighter.fadeTimer, nil)
    end
end

function highlighter.init(object)
    if _hasInit then
        return
    end
    _hasInit = true
    if object == nil then
        game.debug.logWarning('Object nil in default_slider\'s new()')
        return
    end
    local buttonObject = object.find('sprite')
    if buttonObject == nil then
        return
    end
    _graphic = buttonObject.getComponent('image')
    local buttonComponent = buttonObject.getComponent('button')
    if buttonComponent == nil then
        return
    end
    local outlineObject = object.find('outline')
    if outlineObject ~= nil then
        local outline = outlineObject.getComponent('mask')
        if outline ~= nil then
            _mouseoverFader = dofile('data/scripts/ui/dither_fader.lua')
            _mouseoverFader.init(outline, 0, true)
        end
    end
    buttonComponent.onMouseEnter.subscribe(_mouseEnter)
    buttonComponent.onMouseExit.subscribe(_mouseExit)
    _mouseExit()
end

return highlighter