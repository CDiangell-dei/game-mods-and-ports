local goalVisual = {}

local _object = game.object.instantiate('data/scenes/round_goal.json')
local _leftSource = _object.find('left').getComponent('particleSource')
local _rightSource = _object.find('right').getComponent('particleSource')
local _previousIncrement = 0
local _isDisplaying = false
local _burstData = {
    burstCount = 20,
    sprite = 'data/sprites/heart.png',
    minPosition = {
        x = 71 - 9,
        y = 540
    },
    maxPosition = {
        x = 71 - 9,
        y = 540
    },
    minVelocity = {
        x = -40,
        y = -600
    },
    maxVelocity = {
        x = 40,
        y = -400
    },
    minAcceleration = {
        x = 0,
        y = 300
    },
    maxAcceleration = {
        x = 0,
        y = 300
    },
    minStartingSize = {
        x = 18,
        y = 18
    },
    maxStartingSize = {
        x = 18,
        y = 18
    },
    minEndingSize = {
        x = 18,
        y = 18
    },
    maxEndingSize = {
        x = 18,
        y = 18
    },
    minStartingColor = "DD5577",
    maxStartingColor = "DD5577",
    minEndingColor = "DD5577",
    maxEndingColor = "DD5577",
    minLifetime = 4,
    maxLifetime = 4,
}

local function _populateLeftData()
    local y = 0
    local lowest = 540 + 142
    while y < lowest do
        local data = {
            duration = 9999,
            particlesPerSecond = 1.5,
            sprite = 'data/sprites/heart.png',
            minPosition = {
                x = 142,
                y = y
            },
            maxPosition = {
                x = 142,
                y = y
            },
            minVelocity = {
                x = -40,
                y = -40
            },
            maxVelocity = {
                x = -40,
                y = -40
            },
            minStartingSize = {
                x = 18,
                y = 18
            },
            maxStartingSize = {
                x = 18,
                y = 18
            },
            minEndingSize = {
                x = 18,
                y = 18
            },
            maxEndingSize = {
                x = 18,
                y = 18
            },
            minStartingColor = "FF9CB2",
            maxStartingColor = "FF9CB2",
            minEndingColor = "DD5577",
            maxEndingColor = "DD5577",
            minLifetime = 6,
            maxLifetime = 6,
        }
        _leftSource.spawn(data)
        y = y + 56
    end
end

local function _populateRightData()
    local y = 0
    local lowest = 540 + 142
    while y < lowest do
        local data = {
            duration = 9999,
            particlesPerSecond = 1.5,
            sprite = 'data/sprites/heart.png',
            minPosition = {
                x = -18,
                y = y
            },
            maxPosition = {
                x = -18,
                y = y
            },
            minVelocity = {
                x = 40,
                y = -40
            },
            maxVelocity = {
                x = 40,
                y = -40
            },
            minStartingSize = {
                x = 18,
                y = 18
            },
            maxStartingSize = {
                x = 18,
                y = 18
            },
            minEndingSize = {
                x = 18,
                y = 18
            },
            maxEndingSize = {
                x = 18,
                y = 18
            },
            minStartingColor = "FF9CB2",
            maxStartingColor = "FF9CB2",
            minEndingColor = "DD5577",
            maxEndingColor = "DD5577",
            minLifetime = 6,
            maxLifetime = 6,
        }
        _rightSource.spawn(data)
        y = y + 56
    end
end

function goalVisual.stop()
    if _leftSource ~= nil then
        _leftSource.stop()
    end
    if _rightSource ~= nil then
        _rightSource.stop()
    end
    _previousIncrement = 0
    _isDisplaying = false
end

function goalVisual.destroy()
    goalVisual.stop()
    if _object ~= nil then
        _object.destroy()
    end
end

local function _displaySpecificText(path, text, onComplete)
    local dither = dofile('data/scripts/ui/dither_fader.lua')
    dither.init(_object.find(path).getComponent('mask'), 100, false)
    local textComponent = _object.find(path .. '/text').getComponent('text')
    textComponent.setText(text)
    local function completeFadeOut()
        textComponent.setText('')
        dither.fadeTo(100, 0, nil)
        if onComplete ~= nil then
            onComplete()
        end
    end
    local function fadeOut()
        dither.fadeTo(0, 1.0, completeFadeOut)
    end
    game.timer.queue(1.0, fadeOut)
end

local function _displayText(text)
    _isDisplaying = true
    local function onComplete()
        _isDisplaying = false
    end
    _displaySpecificText('leftText', text)
    _displaySpecificText('rightText', text, onComplete)
end

function goalVisual.updateProgress(progress)
    local skip = game.data.getSetting('disableGoalVisuals')
    if skip == 1 then
        return
    end
    local w, h = game.display.getDimensions()
    local ratio = w / h
    if ratio < 1.55 then
        return
    end
    if progress < 2.0 or _object == nil or _isDisplaying then
        return
    end
    local increment = math.floor(progress)
    if increment <= _previousIncrement then
        return
    end
    if _previousIncrement < 2 then
        _populateLeftData()
        _populateRightData()
    end
    _previousIncrement = increment
    if increment == 2 then
        _displayText('goal_double')
        game.audio.playSound('data/sounds/general/goal_1.json')
    elseif increment == 3 then
        _displayText('goal_triple')
        game.audio.playSound('data/sounds/general/goal_2.json')
    else
        _displayText(tostring(increment) .. 'x !')
        if playSound then
            --game.audio.playSound('data/sounds/general/goal_3.json')
        end
    end
    _leftSource.spawn(_burstData)
    _rightSource.spawn(_burstData)
end

return goalVisual
