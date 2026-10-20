local logoControl = {}

function logoControl.init(onComplete)
    local root = engine.objectManager.getRoot().find('root')
    local object = engine.objectManager.instantiate('data/scenes/logo.json', root)
    local function complete()
        object.destroy()
        onComplete()
    end
    local function fade()
        local fader = engine.sandbox.require('data/scripts/screen_fader.lua')
        fader.fadeToWhite(0.5, complete)
    end
    engine.timer.queue(1.0, fade)
end

return logoControl
