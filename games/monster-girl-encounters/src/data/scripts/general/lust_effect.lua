local parent = game.object.getRoot().find('main/viewport')
local object = game.object.instantiate('data/scenes/encounters/lust_effect.json', parent)
local fader = dofile('data/scripts/ui/dither_fader.lua')
fader.init(object.getComponent('mask'), 0, false)
local count = 3
local iteration = 0

local function _pulse()
    if count <= 0 then
        object.destroy()
        return
    end
    local alpha = fader.getAlpha()
    if alpha > 0 then
        fader.fadeTo(0, 1.0, _pulse)
        count = count - 1
        iteration = iteration + 1
    else
        fader.fadeTo(100, 1.0, _pulse)
    end
end

local function _init(pulses)
    if pulses == nil then
        return
    end
    count = pulses - iteration
end

_pulse()

return _init