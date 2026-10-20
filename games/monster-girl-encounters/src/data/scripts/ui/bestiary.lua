local bestiary = {}

local _object = game.object.instantiate('data/scenes/collection_bestiary.json', game.object.getRoot().find('collection'))
local _selectedEntry = nil
local _monsterCount = 0

local function _hasWon(entry)
    return true
end

local function _hasLost(entry)
    return true
end

local function _destroyReplayButtons()
    local replayIntro = _object.find('dataView/buttons/replayIntro')
    if replayIntro ~= nil then
        replayIntro.destroy()
        replayIntro = nil
    end
    local replayBattle = _object.find('dataView/buttons/replayBattle')
    if replayBattle ~= nil then
        replayBattle.destroy()
        replayBattle = nil
    end
    local replayWinOutro = _object.find('dataView/buttons/replayWinOutro')
    if replayWinOutro ~= nil then
        replayWinOutro.destroy()
        replayWinOutro = nil
    end
    local replayLossOutro = _object.find('dataView/buttons/replayLossOutro')
    if replayLossOutro ~= nil then
        replayLossOutro.destroy()
        replayLossOutro = nil
    end
end

local function _destroyOverlay()
    local overlay = _object.find('overlay')
    if overlay ~= nil then
        overlay.destroy()
        overlay = nil
    end
    local closeButton = _object.find('dataView/buttons/close')
    if closeButton ~= nil then
        closeButton.destroy()
        closeButton = nil
    end
end

local function _spawnButton(name, label, callback)
    local parent = _object.find('dataView/buttons')
    local button = game.object.instantiate('data/scenes/collection_option.json', parent)
    button.name = name
    button.find('text/text').getComponent('text').setText(label)
    button.find('text/shadow').getComponent('text').setText(label)

    local textButton = dofile('data/scripts/ui/default_text_button.lua')
    textButton.init(button)
    if callback == nil then
        textButton.deactivate()
    else
        button.find('button').getComponent('button').onClick.subscribe(callback)
    end
end

local _activeOptions = {}

local function _selectOption(index)
    for _, v in pairs(_activeOptions) do
        v.deselect()
    end
    _activeOptions[index].select()
end

local function _changeOverlayVisual(background, sprite)
    local viewport = _object.find('overlay/viewport')
    if background == nil then
        viewport.getComponent('image').setColor(0, 0, 0, 0)
    else
        game.object.setVisual(viewport, background)
        viewport.getComponent('image').setColor(1, 1, 1, 1)
    end

    local image = _object.find('overlay/sprite')
    if sprite == nil then
        image.getComponent('image').setColor(0, 0, 0, 0)
    else
        game.object.setVisual(image, sprite)
        image.getComponent('image').setColor(1, 1, 1, 1)
    end
end

local function _addOptionButton(index, option, activated)
    local parent = _object.find('overlay/phases')
    local button = game.object.instantiate('data/scenes/collection_bestiary_viewport_item.json', parent)
    button.name = tostring(index)
    button.find('label').getComponent('text').setText(tostring(index))

    local defaultButton = dofile('data/scripts/ui/default_highlight_button.lua')
    defaultButton.init(button)
    _activeOptions[index] = defaultButton
    local function setNewOverlay()
        _changeOverlayVisual(option.background, option.sprite)
        _selectOption(index)
    end
    button.find('button').getComponent('button').onClick.subscribe(setNewOverlay)
    if not activated then
        setNewOverlay()
    end
end

local function _addReplayOptions(options)
    if options == nil then
        return
    end
    _activeOptions = {}
    for i=1, #options do
        local option = options[i]
        _addOptionButton(i, option, i > 1)
    end
    if #options <= 1 then
        _object.find('overlay/phases').destroy()
    end
end

local function _spawnIntroButton()
    if _selectedEntry == nil then
        _spawnButton('replayIntro', 'replay_intro', nil)
        return
    end
    local function replayIntro()
        bestiary._spawnVisual(nil, nil)
        _addReplayOptions(_selectedEntry.intro)
    end
    _spawnButton('replayIntro', 'replay_intro', replayIntro)
end

local function _spawnBattleReplayButton()
    if _selectedEntry == nil then
        _spawnButton('replayBattle', 'replay_battle', nil)
        return
    end
    local function replayBattle()
        bestiary._spawnVisual(nil, nil)
        _addReplayOptions(_selectedEntry.battle)
    end
    _spawnButton('replayBattle', 'replay_battle', replayBattle)
end

local function _spawnWinOutroButton()
    if _selectedEntry == nil or not _hasWon(_selectedEntry) then
        _spawnButton('replayWinOutro', 'replay_win', nil)
        return
    end
    local function replayWin()
        bestiary._spawnVisual(nil, nil)
        _addReplayOptions(_selectedEntry.winOutro)
    end
    _spawnButton('replayWinOutro', 'replay_win', replayWin)
end

local function _spawnLossOutroButton()
    if _selectedEntry == nil or not _hasLost(_selectedEntry) then
        _spawnButton('replayLossOutro', 'replay_loss', nil)
        return
    end
    local function replayLoss()
        bestiary._spawnVisual(nil, nil)
        _addReplayOptions(_selectedEntry.failOutro)
    end
    _spawnButton('replayLossOutro', 'replay_loss', replayLoss)
end

local function _spawnVisualButtons()
    _spawnIntroButton()
    _spawnBattleReplayButton()
    _spawnWinOutroButton()
    _spawnLossOutroButton()
end

local function _populateDisplay(entry)
    _destroyReplayButtons()
    _destroyOverlay()
    local ditherer = dofile('data/scripts/ui/staggered_dither.lua')
    local title = _object.find('dataView/title')
    ditherer.queueDitherIn(title.getComponent('mask'), 0)
    title.find('text').getComponent('text').setText(entry.name)
    title.find('shadow').getComponent('text').setText(entry.name)

    local icon = _object.find('dataView/icon')
    ditherer.queueDitherIn(icon.getComponent('mask'), 1)
    game.object.setVisual(icon.find('sprite'), entry.icon)

    local description = _object.find('dataView/description')
    ditherer.queueDitherIn(description.getComponent('mask'), 2)
    description.find('text').getComponent('text').setText(entry.description)
    description.find('shadow').getComponent('text').setText(entry.description)
    _selectedEntry = entry
    _spawnVisualButtons()
    local buttons = _object.find('dataView/buttons')
    ditherer.queueDitherIn(buttons.getComponent('mask'), 3)
    ditherer.executeDither()
end

local function _setEntryLabel(entry, label)
    entry.find('text/text').getComponent('text').setText(label)
    entry.find('text/shadow').getComponent('text').setText(label)
end

local function _spawnEntry(entry, ditherer)
    _monsterCount = _monsterCount + 1
    local parent = _object.find('items/viewport/content')
    local entryObject = game.object.instantiate('data/scenes/collection_bestiary_item.json', parent)
    entryObject.name = tostring(_monsterCount)

    local button = dofile('data/scripts/ui/default_text_button.lua')
    button.init(entryObject)

    local hasWon = _hasWon(entry)
    local hasLost = _hasLost(entry)
    ditherer.queueDitherIn(entryObject.getComponent('mask'), _monsterCount - 1)
    _setEntryLabel(entryObject, entry.name)
    if not hasWon and not hasLost then
        button.deactivate()
        return
    end
    local function onClick()
        _populateDisplay(entry)
    end
    entryObject.find('button').getComponent('button').onClick.subscribe(onClick)
end

local function _sortBattles()
    local data = require('data/scripts/data.lua')
    local function sortEncounter(a, b)
        if a.minBattle ~= b.minBattle then
            return a.minBattle < b.minBattle
        end
        local aName = game.text.getText(a.name)
        local bName = game.text.getText(b.name)
        return aName < bName
    end
    local sorted = {}
    for _, v in pairs(data.battleEncounters) do
        table.insert(sorted, v)
    end
    for _, v in pairs(data.eliteEncounters) do
        table.insert(sorted, v)
    end
    for _, v in pairs(data.bossEncounters) do
        table.insert(sorted, v)
    end
    table.sort(sorted, sortEncounter)
    return sorted
end

function bestiary._spawnVisual(backgroundKey, spriteKey)
    local viewport = game.object.instantiate('data/scenes/collection_bestiary_viewport.json', _object)
    if backgroundKey == nil then
        viewport.find('viewport').getComponent('image').setColor(0, 0, 0, 0)
    else
        game.object.setVisual(viewport.find('viewport'), backgroundKey)
    end
    if spriteKey == nil then
        viewport.find('sprite').getComponent('image').setColor(0, 0, 0, 0)
    else
        game.object.setVisual(viewport.find('sprite'), spriteKey)
    end
    local ditherer = dofile('data/scripts/ui/staggered_dither.lua')
    ditherer.queueDitherIn(viewport.getComponent('mask'), 0)
    _destroyReplayButtons()

    local function close()
        _destroyOverlay()
        _spawnVisualButtons()
    end
    _spawnButton('close', 'close_button', close)
    ditherer.queueDitherIn(_object.find('dataView/buttons').getComponent('mask'), 0)
    ditherer.executeDither()
end

function bestiary.destroy()
    if _object == nil then
        return
    end
    _object.destroy()
    _object = nil
end

local function _init()
    local battles = _sortBattles()
    local ditherer = dofile('data/scripts/ui/staggered_dither.lua')
    for _, battle in ipairs(battles) do
        _spawnEntry(battle, ditherer)
    end
    ditherer.queueDitherIn(_object.find('dataView').getComponent('mask'), 0)
    ditherer.executeDither()
end

_init()

return bestiary
