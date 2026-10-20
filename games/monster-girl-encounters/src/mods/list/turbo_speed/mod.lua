local hooks = {}

local _speeds = { 1.0, 2.0, 4.0 }
local _labels = { "1x", "2x", "4x" }
local _currentSpeedIndex = 1

function hooks.onMainUiReady(parent)
    local turboObj = game.object.instantiate('data/scenes/turbo_speed.json', parent)
    local label = turboObj.find('button/label').getComponent('text')
    
    _currentSpeedIndex = 1
    game.timer.setTimescale(1.0)
    label.setText("1x")

    local function toggleSpeed()
        _currentSpeedIndex = (_currentSpeedIndex % #_speeds) + 1
        local newSpeed = _speeds[_currentSpeedIndex]
        game.timer.setTimescale(newSpeed)
        label.setText(_labels[_currentSpeedIndex])
        game.audio.playSound('data/sounds/general/button.json')
    end

    turboObj.find('button').getComponent('button').onClick.subscribe(toggleSpeed)
end

return { hooks = hooks }
