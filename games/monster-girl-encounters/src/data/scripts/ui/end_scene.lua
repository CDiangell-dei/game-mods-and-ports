local endScene = {}

local _object
local _count = 0
local _confirmButton

local function _addStat(title, amount, ditherer)
    _count = _count + 1
    local parent = _object.find('stats/viewport/content')
    local item = game.object.instantiate('data/scenes/end_screen_item.json', parent)
    item.name = tostring(_count)
    item.find('title').getComponent('text').setText(title)
    amount = math.floor(amount)
    local text = string.format('%.5g', amount)
    item.find('amount').getComponent('text').setText(tostring(text))
    ditherer.queueDitherIn(item.getComponent('mask'), _count)
end

local function _loadStats()
    local ditherer = dofile('data/scripts/ui/staggered_dither.lua')
    ditherer.queueDitherIn(_object.find('title').getComponent('mask'), 0)
    local tracker = require('data/scripts/stat_tracker.lua')
    _addStat('stat_total_exhaustion', tracker.totalExhaustionDealt, ditherer)
    _addStat('stat_maximum_pump', tracker.maximumExhaustionPerPump, ditherer)
    _addStat('stat_gold_gained', tracker.goldGained, ditherer)
    _addStat('stat_gold_spent', tracker.goldSpent, ditherer)
    _addStat('stat_new_items', tracker.newItems, ditherer)
    _addStat('stat_new_battles', tracker.newBattles, ditherer)
    _addStat('stat_normal_battles', tracker.normalBattles, ditherer)
    _addStat('stat_elite_battles', tracker.eliteBattles, ditherer)
    _addStat('stat_random_encounters', tracker.randomEncounters, ditherer)
    _addStat('stat_shops', tracker.shopsEntered, ditherer)
    _addStat('stat_legendary', tracker.legendaryItems, ditherer)
    _addStat('stat_fairies', tracker.fairiesVisited, ditherer)
    ditherer.executeDither(_confirmButton.activate, 1.0)
end

local function _spawnDefaultScene(text)
    _object = game.object.instantiate('data/scenes/lose_screen.json')
    _object.find('title/text').getComponent('text').setText(text)
    _confirmButton = dofile('data/scripts/ui/default_text_button.lua')
    local button = _object.find('confirmButton')
    _confirmButton.init(button)
    _confirmButton.deactivate()
    button.find('button').getComponent('button').onClick.subscribe(game.scene.enterTitle)
    local function complete()
        _loadStats()
    end
    game.scene.fadeIn(1.5, complete)
end

local function _spawnWinScene3()
    _object.destroy()
    _object = game.object.instantiate('data/scenes/win_screen.json')
    local function finalComplete()
        _object.destroy()
        _spawnDefaultScene('game_win')
    end
    local function complete()
        _object.getComponent('button').onClick.unsubscribe(complete)
        game.scene.fadeToBlack(2.0, finalComplete)
    end
    local function end_art()
        _object.getComponent('button').onClick.subscribe(complete)
    end
    game.scene.fadeIn(3.0, end_art)
end

local function _spawnWinScene2()
    local dialogueHandler = require('data/scripts/dialogue/dialogue_handler.lua')
    dialogueHandler.close()
    game.scene.fadeToBlack(0.5, _spawnWinScene3)
end

local function _spawnWinScene()
    _object = game.object.instantiate('data/scenes/win_screen_dialogue.json')
    local dialogueBox = _object.find('dialogueBox')
    local button = dialogueBox.getComponent('button')
    local dialogueHandler = require('data/scripts/dialogue/dialogue_handler.lua')
    dialogueHandler.close()
    button.onClick.subscribe(dialogueHandler.progress)
    dialogueHandler.talk(dialogueBox, 'data/dialogue/win.json', _spawnWinScene2, false)
    game.scene.fadeIn(0.5, nil)
end

local function _init()
    game.audio.playMusic('data/sounds/ending.json')
    if game.control.lives > 0 then
        _spawnWinScene()
    else
        _spawnDefaultScene('game_over')
    end
end

_init()

return endScene
