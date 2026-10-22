local slider = {
    mouseoverSound = 'data/sounds/general/mouseover.json',
    mouseDownSound = 'data/sounds/general/button_press.json',
    mouseUpSound = 'data/sounds/general/button_release.json',
    mouseEnterColor = { r = 0.427451, g = 0.427451, b = 0.5294118, a  = 1.0 },
    defaultColor = { r = 0.3333333, g = 0.3333333, b = 0.4431373, a  = 1.0 },
}

local _hasInit = false

local function _mouseEnter()
    if slider.mouseoverSound ~= nil then
        game.audio.playSound(slider.mouseoverSound, nil, true)
    end
    if slider.graphic ~= nil then
        slider.graphic.setColor(slider.mouseEnterColor.r, slider.mouseEnterColor.g,
            slider.mouseEnterColor.b, slider.mouseEnterColor.a)
    end
end

local function _mouseExit()
    if slider.graphic ~= nil then
        slider.graphic.setColor(slider.defaultColor.r, slider.defaultColor.g,
            slider.defaultColor.b, slider.defaultColor.a)
    end
end

local function _mouseDown()
    if slider.mouseDownSound ~= nil then
        game.audio.playSound(slider.mouseDownSound, nil, true)
    end
end

local function _mouseUp()
    if slider.mouseUpSound ~= nil then
        game.audio.playSound(slider.mouseUpSound, nil, true)
    end
end

function slider.init(object, graphic)
    if _hasInit then
        return
    end
    _hasInit = true
    slider.graphic = graphic
    if object == nil then
        game.debug.logWarning('Object nil in default_slider\'s new()')
        return
    end
    local buttonComponent = object.getComponent('button')
    if buttonComponent == nil then
        return
    end
    buttonComponent.onMouseEnter.subscribe(_mouseEnter)
    buttonComponent.onMouseExit.subscribe(_mouseExit)
    buttonComponent.onMouseDown.subscribe(_mouseDown)
    buttonComponent.onMouseUp.subscribe(_mouseUp)
    _mouseExit()
end

return slider