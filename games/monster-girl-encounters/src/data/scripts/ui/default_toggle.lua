local toggle = {
    mouseoverSound = 'data/sounds/general/mouseover.json',
    toggleOnSound = 'data/sounds/general/button_press.json',
    toggleOffSound = 'data/sounds/general/button_release.json',
    fadeTimer = 0.1,
    onToggle = dofile('data/scripts/event_receiver.lua'),
    mouseEnterColor = { r = 0.427451, g = 0.427451, b = 0.5294118, a  = 1.0 },
    defaultColor = { r = 0.3333333, g = 0.3333333, b = 0.4431373, a  = 1.0 },
}

local _isOn = false
local _hasInit = false

local function _mouseEnter()
    if toggle.mouseoverSound ~= nil then
        game.audio.playSound(toggle.mouseoverSound, nil, true)
    end
    if toggle.graphic ~= nil then
        toggle.graphic.setColor(toggle.mouseEnterColor.r, toggle.mouseEnterColor.g,
            toggle.mouseEnterColor.b, toggle.mouseEnterColor.a)
    end
end

local function _mouseExit()
    if toggle.graphic ~= nil then
        toggle.graphic.setColor(toggle.defaultColor.r, toggle.defaultColor.g,
            toggle.defaultColor.b, toggle.defaultColor.a)
    end
end

local function _click()
    toggle.setIsOn(not _isOn)
    if _isOn then
        if toggle.toggleOnSound ~= nil then
            game.audio.playSound(toggle.toggleOnSound, nil, true)
        end
    else
        if toggle.toggleOffSound ~= nil then
            game.audio.playSound(toggle.toggleOffSound, nil, true)
        end
    end
end

function toggle.init(object, graphic)
    if _hasInit then
        return
    end
    _hasInit = true
    toggle.graphic = graphic
    if object == nil then
        game.debug.logWarning('Object nil in default_toggle\'s new()')
        return
    end
    local buttonComponent = object.getComponent('button')
    if buttonComponent == nil then
        return
    end
    buttonComponent.onMouseEnter.subscribe(_mouseEnter)
    buttonComponent.onMouseExit.subscribe(_mouseExit)
    buttonComponent.onClick.subscribe(_click)
    local checkmark = object.find('checkmark')
    if checkmark ~= nil then
        toggle.checkmark = checkmark.getComponent('image')
        if toggle.checkmark == nil then
            toggle.checkmark = checkmark.getComponent('text')
        end
    end
    _mouseExit()
end

function toggle.setIsOn(isOn)
    _isOn = isOn
    if _isOn then
        if toggle.checkmark ~= nil then
            toggle.checkmark.setColor(1.0, 1.0, 1.0, 1.0)
        end
    else
        if toggle.checkmark ~= nil then
            toggle.checkmark.setColor(0, 0, 0, 0)
        end
    end
    toggle.onToggle.invoke(_isOn)
end

return toggle