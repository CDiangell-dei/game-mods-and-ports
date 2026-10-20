local splash = {}

local _fileLoader = engine.dofile('data/scripts/file_loader.lua')
local _obj = engine.objectManager.instantiate('data/scenes/splash.json')
local _onComplete
local _dithers = {
    [0] = engine.fileSystem.loadSprite('data/sprites/dither/0.png'),
    [10] = engine.fileSystem.loadSprite('data/sprites/dither/10.png'),
    [20] = engine.fileSystem.loadSprite('data/sprites/dither/20.png'),
    [30] = engine.fileSystem.loadSprite('data/sprites/dither/30.png'),
    [40] = engine.fileSystem.loadSprite('data/sprites/dither/40.png'),
    [50] = engine.fileSystem.loadSprite('data/sprites/dither/50.png'),
    [60] = engine.fileSystem.loadSprite('data/sprites/dither/60.png'),
    [70] = engine.fileSystem.loadSprite('data/sprites/dither/70.png'),
    [80] = engine.fileSystem.loadSprite('data/sprites/dither/80.png'),
    [90] = engine.fileSystem.loadSprite('data/sprites/dither/90.png'),
    [100] = engine.fileSystem.loadSprite('data/sprites/dither/100.png'),
}
local counter = 0

local function _setAccentedLogo()
    local image = _obj.find('slider/fill/sprite').getComponent('image')
    local sprite = engine.fileSystem.loadSprite('data/sprites/logo_accent.png')
    image.setSprite(sprite)
end

local function _updateLoadingBar()
    local slider = _obj.find('slider').getComponent('slider')
    local progress = 0
    if love.system.getOS() == 'Web' then
        --No need to preload for webgl
        counter = counter + 1
        progress = counter
    else
        _fileLoader.update()
        progress = _fileLoader.getProgress()
    end
    slider.setValue(progress * 100)
    return progress
end

local function _getMask(progress)
    local converted = 100 - (progress * 100)
    local currentAmount = -10
    local currentDither = nil
    for amount, dither in pairs(_dithers) do
        if converted >= amount and currentAmount < amount then
            currentAmount = amount
            currentDither = dither
        end
    end
    return currentDither or _dithers[0]
end

local function _update()
    local timer = 0.5
    while timer > 0 do
        timer = timer - engine.timer.getDeltaTime()
        coroutine.yield()
    end
    local progress = 0
    while progress < 1.0 do
        progress = _updateLoadingBar()
        coroutine.yield()
    end
    timer = 0.5
    while timer > 0 do
        timer = timer - engine.timer.getDeltaTime()
        coroutine.yield()
    end
    engine.audio.play('data/sounds/general/tile_super.json')
    _setAccentedLogo()
    timer = 0.5
    while timer > 0 do
        timer = timer - engine.timer.getDeltaTime()
        coroutine.yield()
    end
    timer = 0
    local mask = _obj.getComponent('mask')
    while timer < 0.5 do
        timer = timer + engine.timer.getDeltaTime()
        local fade = timer / 0.5
        local sprite = _getMask(fade)
        mask.setSprite(sprite)
        coroutine.yield()
    end
    _onComplete()
end

function splash.init(onComplete)
    _onComplete = onComplete
    engine.timer.startCoroutine(_update)
end

return splash
