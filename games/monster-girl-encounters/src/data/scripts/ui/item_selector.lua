local itemSelectorUI = {}

local _ditherer = dofile('data/scripts/ui/staggered_dither.lua')
local _object
local _selector
local _pendingAdditions = {}
local _selectedCount = 0
local _count = 0
local _confirmButton

local function _toggleSelect(index, item, button)
    if _pendingAdditions[index] ~= nil then
        _pendingAdditions[index] = nil
        _selectedCount = _selectedCount - 1
        button.deselect()
        _confirmButton.deactivate()
        return
    end
    if _selectedCount >= _selector.itemMaxCount then
        return
    end
    _pendingAdditions[index] = item
    _selectedCount = _selectedCount + 1
    button.select()
    if _selectedCount == _selector.itemMaxCount then
        _confirmButton.activate()
    end
end

function itemSelectorUI.instantiate(selector)
    _selector = selector
    _object = game.object.instantiate('data/scenes/item_selection.json')
    local function confirm()
        if _selectedCount < _selector.itemMaxCount then
            return
        end
        _selector.setItems(_pendingAdditions)
        _selector.enterGame()
    end

    _confirmButton = dofile('data/scripts/ui/default_text_button.lua')
    _confirmButton.init(_object.find('confirmButton'))
    _object.find('confirmButton/button').getComponent('button').onClick.subscribe(confirm)
    _confirmButton.deactivate()

    local returnButton = dofile('data/scripts/ui/default_text_button.lua')
    returnButton.init(_object.find('returnButton'))
    --_object.find('returnButton/button').getComponent('button').onClick.subscribe(_selector.enterModeSelection)
    _object.find('returnButton/button').getComponent('button').onClick.subscribe(_selector.returnToTitle)

    local selectionText = game.text.getText('item_selection')
    local count = tostring(selector.itemMaxCount)
    local title = string.gsub(selectionText, '(<var=count>)', function(_) return count end)
    _object.find('title/text').getComponent('text').setText(title)
end

function itemSelectorUI.destroy()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
end

function itemSelectorUI.addItem(item)
    _count = _count + 1
    local parent = _object.find('items')
    local itemObject = game.object.instantiate('data/scenes/item_selection_item.json', parent)
    itemObject.name = tostring(_count)
    game.object.setVisual(itemObject.find('button'), item.icon)

    local row = math.ceil(_count / 3)
    _ditherer.queueDitherIn(itemObject.getComponent('mask'), row + 1)
    local index = _count
    local button = dofile('data/scripts/ui/default_highlight_button.lua')
    button.init(itemObject)
    local function selectItem()
        _toggleSelect(index, item, button)
    end
    local buttonComponent = itemObject.find('button').getComponent('button')
    buttonComponent.onClick.subscribe(selectItem)
    local tooltip = nil
    local function spawnTooltip()
        if tooltip ~= nil then
            tooltip.destroy()
        end
        tooltip = dofile('data/scripts/ui/tooltip.lua')
        tooltip.initInactive(item)
    end
    local function destroyTooltip()
        if tooltip ~= nil then
            tooltip.destroy()
            tooltip = nil
        end
    end
    buttonComponent.onMouseEnter.subscribe(spawnTooltip)
    buttonComponent.onMouseExit.subscribe(destroyTooltip)
end

function itemSelectorUI.fadeIn()
    _ditherer.queueDitherIn(_object.find('title').getComponent('mask'), 1)
    _ditherer.executeDither(nil, 0.3)
end

return itemSelectorUI
