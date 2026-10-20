local cutsceneInitializer = {}

local _cutscenePlayer = dofile('data/scripts/ui/cutscene.lua')
local _scenes = {
    {
        duration = 3,
        visual = 'data/sprites/dither/0.png'
    },
    {
        dialogue = 'data/dialogue/intro/1.json',
        visual = 'data/sprites/intro/1.png',
    },
    {
        dialogue = 'data/dialogue/intro/2.json',
        visual = 'data/sprites/intro/1.png',
    },
    {
        dialogue = 'data/dialogue/intro/3.json',
        visual = 'data/sprites/intro/2.png',
    },
    {
        dialogue = 'data/dialogue/intro/4.json',
        visual = 'data/sprites/intro/3.png',
    },
    {
        dialogue = 'data/dialogue/intro/5.json',
        visual = 'data/sprites/intro/4.png',
    },
    {
        dialogue = 'data/dialogue/intro/6.json',
        visual = 'data/sprites/intro/4.png',
    },
    {
        dialogue = 'data/dialogue/intro/7.json',
        visual = 'data/sprites/intro/5.png',
    },
    {
        dialogue = 'data/dialogue/intro/8.json',
        visual = 'data/sprites/intro/6.png',
    },
    {
        dialogue = 'data/dialogue/intro/9.json',
        visual = 'data/sprites/intro/7.png',
    },
    {
        dialogue = 'data/dialogue/intro/10.json',
        visual = 'data/sprites/intro/8.png',
    },
}
local _onComplete = nil

local function _loadControl()
    _cutscenePlayer.destroy()
    game.data.setProgress('intro_complete', 1)
    game.control = require('data/scripts/game_control.lua')
	game.control.setSeed(os.time())
    game.control.gainGold(10)
    game.control.init()
    require('data/scripts/stat_tracker.lua')

    local data = require('data/scripts/data.lua')
    local canteen = data.tiles['canteen']
    local sandwich = data.tiles['sandwich']
    local clover = data.tiles['lucky_clover']
    game.control.tiles.setFirstOpenSlot(canteen)
    game.control.tiles.setFirstOpenSlot(sandwich)
    game.control.tiles.setFirstOpenSlot(clover)

    if _onComplete then
        _onComplete()
    end
end

local function _complete()
    game.audio.playSound('data/sounds/general/transition.json')
    game.scene.fadeToBlack(0.5, _loadControl)
end

function cutsceneInitializer.init(onComplete)
    _onComplete = onComplete
    _cutscenePlayer.instantiate(_scenes, _complete)
    game.scene.fadeIn(2.0, nil)
    game.audio.playMusic('data/sounds/ambient1.json')
end

return cutsceneInitializer
