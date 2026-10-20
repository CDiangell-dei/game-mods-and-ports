local itemMenu = {}

local _object = game.object.instantiate('data/scenes/collection_items.json', game.object.getRoot().find('collection'))
local _theme = require('data/scripts/ui/theme.lua')
local _itemCount = 0

local function _isUnlocked(item)
    local hasObtained = game.data.getProgress('obtained_' .. item.key)
    return hasObtained == 1
end

local function _setupItemButton(itemObject, item)
    if item == nil then
        game.debug.log('setting up item that is nil: ' ..tostring(itemObject.name))
    end
    local button = dofile('data/scripts/ui/default_highlighter.lua')
    button.init(itemObject)
    local tooltip = nil
    local function onMouseEnter()
        if tooltip ~= nil then
            tooltip.destroy()
        end
        tooltip = dofile('data/scripts/ui/tooltip.lua')
        tooltip.initInactive(item)
    end
    local function onMouseExit()
        if tooltip ~= nil then
            tooltip.destroy()
            tooltip = nil
        end
    end
    itemObject.find('sprite').getComponent('button').onMouseEnter.subscribe(onMouseEnter)
    itemObject.find('sprite').getComponent('button').onMouseExit.subscribe(onMouseExit)
end

local function _spawnItem(item, ditherer)
    _itemCount = _itemCount + 1
    local parent = _object.find('viewport/content')
    local itemObject = game.object.instantiate('data/scenes/collection_items_item.json', parent)
    itemObject.name = tostring(_itemCount)

    local level = (_itemCount - 1) % 8
    ditherer.queueDitherIn(itemObject.getComponent('mask'), level)
    game.object.setVisual(itemObject.find('sprite'), item.icon)
    if _isUnlocked(item) then
        _theme.colorRarityImage(itemObject.find('outline/color').getComponent('image'), item.rarity)
        _setupItemButton(itemObject, item)
    else
        local image = itemObject.find('sprite').getComponent('image')
        image.setColor(0.25, 0.25, 0.25, 1.0)
    end
end

local function _sortByItemName(items)
    local function sortByName(a, b)
        local aName = game.text.getText(a.name)
        local bName = game.text.getText(b.name)
        return aName < bName
    end
    local sorted = {}
    for _, v in pairs(items) do
        if v.subtype ~= 'junk' then
            table.insert(sorted, v)
        end
    end
    table.sort(sorted, sortByName)
    return sorted
end

function itemMenu.destroy()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
end

local function _init()
    local data = require('data/scripts/data.lua')
    _itemCount = 0
    local ditherer = dofile('data/scripts/ui/staggered_dither.lua')
    local sortedTiles = _sortByItemName(data.tiles)
    for _, tile in ipairs(sortedTiles) do
        _spawnItem(tile, ditherer)
    end
    ditherer.executeDither()
end

_init()

return itemMenu
