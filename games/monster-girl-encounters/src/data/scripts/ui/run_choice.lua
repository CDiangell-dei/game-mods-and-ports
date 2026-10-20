-- MOD (save/continue): screen shown after Start when a saved run exists.
-- Item 1 = continue, item 2 = new run (see game_selector.enterRunChoice).
local runChoiceUI = {}

local _object
local _ditherer = dofile('data/scripts/ui/staggered_dither.lua')
local _selector
local _selected = nil
local _count = 0
local _confirmButton
local _items = {}
local _locked = {}

local function _deselect(index)
    _selected = nil
    _items[index].deselect()
end

local function _toggleSelection(index)
    if _locked[index] then
        game.audio.playSound('data/sounds/general/fail.json')
        return
    end
    if _selected == index then
        _deselect(index)
        _confirmButton.deactivate()
        return
    end
    if _selected ~= nil then
        _deselect(_selected)
    else
        _confirmButton.activate()
    end
    _selected = index
    _items[index].select()
end

function runChoiceUI.instantiate(selector)
    _selector = selector
    _object = game.object.instantiate('data/scenes/run_choice.json')
    local function confirm()
        if _selected == nil then
            return
        end
        selector.confirmRunChoice(_selected)
    end
    _confirmButton = dofile('data/scripts/ui/default_text_button.lua')
    _confirmButton.init(_object.find('confirmButton'))
    _object.find('confirmButton/button').getComponent('button').onClick.subscribe(confirm)
    _confirmButton.deactivate()

    local returnButton = dofile('data/scripts/ui/default_text_button.lua')
    returnButton.init(_object.find('returnButton'))
    _object.find('returnButton/button').getComponent('button').onClick.subscribe(selector.returnToTitle)
end

function runChoiceUI.destroy()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
end

function runChoiceUI.addItem(entry)
    _count = _count + 1
    local index = _count
    local parent = _object.find('encounters/viewport/content')
    local item = game.object.instantiate('data/scenes/mode_selection_item.json', parent)
    item.name = tostring(index)
    game.object.setVisual(item.find('icon'), entry.icon)
    local button = dofile('data/scripts/ui/default_highlight_button.lua')
    button.init(item)
    item.find('button').getComponent('button').onClick.subscribe(function()
        _toggleSelection(index)
    end)
    item.find('title').getComponent('text').setText(entry.name)
    item.find('description').getComponent('text').setText(entry.description)
    _items[index] = button
    _locked[index] = entry.locked == true
    _ditherer.queueDitherIn(item.getComponent('mask'), 2)
end

function runChoiceUI.fadeIn()
    _ditherer.queueDitherIn(_object.find('title').getComponent('mask'), 1)
    _ditherer.executeDither(nil, 0.3)
end

return runChoiceUI
