local modeSelectorUI = {}

local _object
local _ditherer = dofile('data/scripts/ui/staggered_dither.lua')
local _selector
local _selected = nil
local _count = 0
local _confirmButton
local _modes = {}

local function _getSeedFromString(s)
    if s == nil or #s < 1 then
        return nil
    end
    local h = 5381
    local count = #s
    for i=1, count do
        h = h * 32 + h + string.byte(s, i)
    end
    return h
end

local function _deselect(index)
    _selected = nil
    _modes[index].deselect()
end

local function _toggleSelection(index)
    if _selected == index then
        _deselect(index)
        _selected = nil
        _confirmButton.deactivate()
        return
    end
    if _selected ~= nil then
        _deselect(_selected)
    else
        _confirmButton.activate()
    end
    _selected = index
    _selector.setMode(_selected)
    _modes[index].select()
end

function modeSelectorUI.instantiate(selector)
    _selector = selector
    _object = game.object.instantiate('data/scenes/mode_selection.json')
    local function confirm()
        if _selected == nil then
            return
        end
        local modeInfo = selector.modes[_selected]
        if modeInfo ~= nil and modeInfo.isSandbox then
            selector.enterGame()
        else
            selector.enterItemSelection()
        end
    end
    _confirmButton = dofile('data/scripts/ui/default_text_button.lua')
    _confirmButton.init(_object.find('confirmButton'))
    _object.find('confirmButton/button').getComponent('button').onClick.subscribe(confirm)
    _confirmButton.deactivate()

    local returnButton = dofile('data/scripts/ui/default_text_button.lua')
    returnButton.init(_object.find('returnButton'))
    _object.find('returnButton/button').getComponent('button').onClick.subscribe(selector.returnToTitle)

    local inputButton = dofile('data/scripts/ui/default_highlight_button.lua')
    inputButton.init(_object.find('customSeed'))

    local inputToggle = dofile('data/scripts/ui/default_toggle.lua')
    inputToggle.init(_object.find('customSeed/toggle'))

    local function _toggleOn(_)
        inputToggle.setIsOn(true)
    end
    local function _sendSeed(s)
        if s == nil or s == '' then
            inputToggle.setIsOn(false)
            return
        end
        local seed = _getSeedFromString(s)
        selector.setSeed(seed)
    end
    local function _verifyToggle(isOn)
        if isOn then
            local s = _object.find('customSeed/button').getComponent('input').getText()
            local seed = _getSeedFromString(s)
            selector.setSeed(seed)
            inputButton.select()
        else
            selector.setSeed(nil)
            inputButton.deselect()
        end
    end
    _object.find('customSeed/button').getComponent('button').onClick.subscribe(_toggleOn)
    _object.find('customSeed/button').getComponent('input').onEndInput.subscribe(_sendSeed)
    inputToggle.onToggle.subscribe(_verifyToggle)
end

function modeSelectorUI.destroy()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
end

function modeSelectorUI.addItem(mode)
    _count = _count + 1
    local parent = _object.find('encounters/viewport/content')
    local item = game.object.instantiate('data/scenes/mode_selection_item.json', parent)
    item.name = tostring(_count)
    game.object.setVisual(item.find('icon'), mode.icon)
    local index = _count
    local function selectItem()
        _toggleSelection(index)
    end
    local button = dofile('data/scripts/ui/default_highlight_button.lua')
    button.init(item)
    item.find('button').getComponent('button').onClick.subscribe(selectItem)
    item.find('title').getComponent('text').setText(mode.name)
    item.find('description').getComponent('text').setText(mode.description)
    _modes[index] = button
    _ditherer.queueDitherIn(item.getComponent('mask'), 2)
end

function modeSelectorUI.fadeIn()
    _ditherer.queueDitherIn(_object.find('title').getComponent('mask'), 1)
    _ditherer.queueDitherIn(_object.find('customSeed').getComponent('mask'), 3)
    _ditherer.executeDither(nil, 0.3)
end

return modeSelectorUI