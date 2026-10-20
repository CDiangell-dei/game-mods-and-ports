local loseHandler = {}

local _onComplete
local _isComplete = false

local function _animateText(screen)
    local shadow = screen.find('label/shadow').getComponent('text')
    local text = screen.find('label/text').getComponent('text')
    local breedingText = game.text.getText('breeding_progress')
    breedingText = breedingText or ''
    local textLength = game.string.len(breedingText)
    breedingText = breedingText .. '...'
    shadow.setText(breedingText)
    text.setText(breedingText)

    local iterationTime = 0.33
    local elipsis = 0
    local function iterateElipsis()
        if _isComplete then
            return
        end
        elipsis = elipsis + 1
        if elipsis > 3 then
            elipsis = 1
        end
        shadow.setMaxVisibleCharacters(textLength + elipsis)
        text.setMaxVisibleCharacters(textLength + elipsis)
        game.timer.queue(iterationTime, iterateElipsis)
    end

    iterateElipsis()
end

local function _loseHealth()
    local object = game.object.getRoot().find('main')
    local count = object.find('hearts').getChildCount()
    local heart = object.find('hearts').getChild(count)
    local fullDither = dofile('data/scripts/ui/dither_fader.lua')
    fullDither.init(heart.getComponent('mask'), 100, false)
    local dither = dofile('data/scripts/ui/dither_fader.lua')
    dither.init(heart.find('cover').getComponent('mask'), 0, false)

    local function completeFinalFade()
        _isComplete = true
        heart.destroy()
        if _onComplete ~= nil then
            _onComplete()
        end
    end
    local function fade2()
        fullDither.fadeTo(0, 1.0, completeFinalFade)
    end
    local function flash1()
        fullDither.fadeTo(100, 0, fade2)
    end
    local function fade1()
        fullDither.fadeTo(0, 0.5, flash1)
    end

    dither.fadeTo(100, 0, fade1)
end

local function _fadeInScreen(screen)
    local dither = dofile('data/scripts/ui/dither_fader.lua')
    dither.init(screen.getComponent('mask'), 0, false)
    dither.fadeTo(100, 0.5, nil)
end

local function _plapLoop(screen)
    local loopCount = 0
    local totalLoops = 5
    local animator = screen.find('background').getComponent('animator')
    local function incrementLoop()
        loopCount = loopCount + 1
        if loopCount < totalLoops then
            game.audio.playSound('data/sounds/general/health_plap.json')
        elseif loopCount == totalLoops then
            animator.setSpeed(0.5)
            game.audio.playSound('data/sounds/general/lose_health.json')
            _loseHealth()
        else
            animator.stop()
        end
    end
    animator.onCompletion.subscribe(incrementLoop)
end

local function _spawnLoseScreen()
    local parent = game.object.getRoot().find('main/viewport/battle')
    local screen = game.object.instantiate('data/scenes/encounters/lose.json', parent)
    _animateText(screen)
    _fadeInScreen(screen)
    _plapLoop(screen)
end

function loseHandler.init(onComplete)
    _onComplete = onComplete
    _spawnLoseScreen()
end

return loseHandler
