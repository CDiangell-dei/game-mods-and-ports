local shopHelper = {}

local _items = {}
local _theme = require('data/scripts/ui/theme.lua')
local _mods = require('mods/mod_manager.lua') -- MOD
local _outlineDitherers = {}
local _isRerolling = false
local _object
local _refreshRates = nil
local _pendingRefresh = false
local _confirmObject = nil --MOD (sell confirm): popup currently open, nil when closed
local _tooltipClosers = {} --MOD (nil fix): per-slot functions that destroy the hover tooltip

local function _setTileInputLocked(locked)
    local ui = game.control.ui
    if ui ~= nil and ui.setTileInputLocked ~= nil then
        ui.setTileInputLocked(locked)
    end
end

-- MOD (sell confirm): always safe to call, even if the popup is already gone.
local function _closeSellConfirmation()
    if _confirmObject ~= nil then
        _confirmObject.destroy()
        _confirmObject = nil
    end
    _setTileInputLocked(false)
end

-- MOD (sell confirm): the real sale. Re-validates the tile because the popup
-- stays open for a while and the inventory may have changed in the meantime.
local function _executeSell(itemIndex, expectedTile)
    local tile = game.control.tiles.getTile(itemIndex)
    if tile == nil or tile ~= expectedTile then
        game.audio.playSound('data/sounds/general/fail.json')
        return
    end
    game.audio.playSound('data/sounds/general/sell.json')
    game.control.encounter.sellItem(tile)
    game.control.tiles.destroyTile(itemIndex)
    _pendingRefresh = true
end

local function _setTextPair(parent, path, text)
    if parent == nil then
        return
    end
    local object = parent.find(path)
    if object == nil then
        return
    end
    local component = object.getComponent('text')
    if component ~= nil then
        component.setText(text)
    end
end

local function _buildSellQuestion(tile)
    local amount = game.control.encounter.getSellAmount(tile)
    local itemName = ''
    if tile.data ~= nil and tile.data.name ~= nil then
        itemName = game.text.getText(tile.data.name) or ''
    end
    local question = game.text.getText('sell_confirm_title') or ''
    question = string.gsub(question, '{item}', function() return itemName end)
    question = string.gsub(question, '{price}', function() return tostring(amount) end)
    return question
end

-- Called by the trash receiver when a tile is dropped on it. Returns false so
-- the inventory does NOT destroy the tile by itself: the sale only happens
-- if the player presses Yes.
local function _sellItem(itemIndex)
    local tile = game.control.tiles.getTile(itemIndex)
    if tile == nil then
        return false
    end
    -- MOD: the sell confirmation is native on Android. On PC it only exists while the
    -- sell_confirm mod is active (mods/list/sell_confirm); otherwise the sale is immediate.
    local needsConfirmation = _mods.filter('sellNeedsConfirmation', love.system.getOS() == 'Android')
    if not needsConfirmation then
        game.audio.playSound('data/sounds/general/sell.json')
        game.control.encounter.sellItem(tile)
        _pendingRefresh = true
        return true --the inventory destroys the tile itself
    end
    if _confirmObject ~= nil then
        return false --a confirmation is already open, ignore extra drops
    end
    local parent = game.object.getRoot().find('main/viewport')
    if parent == nil then
        parent = _object
    end
    if parent == nil then
        game.audio.playSound('data/sounds/general/fail.json')
        return false
    end
    local popup = game.object.instantiate('data/scenes/shop_sell_confirmation.json', parent)
    if popup == nil then
        game.audio.playSound('data/sounds/general/fail.json')
        return false
    end
    _confirmObject = popup
    _setTileInputLocked(true)
    local question = _buildSellQuestion(tile)
    _setTextPair(popup, 'title/text', question)
    _setTextPair(popup, 'title/shadow', question)

    local resolved = false
    local function answer(sell)
        if resolved then
            return
        end
        resolved = true
        _closeSellConfirmation()
        if sell then
            _executeSell(itemIndex, tile)
        else
            game.audio.playSound('data/sounds/general/drop.json')
            game.control.ui.updateTile(itemIndex)
        end
    end
    local function onYes()
        answer(true)
    end
    local function onNo()
        answer(false)
    end

    local yesObject = popup.find('yesButton')
    local noObject = popup.find('noButton')
    if yesObject == nil or noObject == nil or
        yesObject.find('button') == nil or noObject.find('button') == nil then
        --broken popup: cancel safely instead of selling without confirmation
        resolved = true
        _closeSellConfirmation()
        game.control.ui.updateTile(itemIndex)
        return false
    end
    local yesButton = dofile('data/scripts/ui/default_text_button.lua')
    yesButton.init(yesObject)
    local noButton = dofile('data/scripts/ui/default_text_button.lua')
    noButton.init(noObject)
    yesObject.find('button').getComponent('button').onClick.subscribe(onYes)
    noObject.find('button').getComponent('button').onClick.subscribe(onNo)
    return false
end

local function _populateTrashValue(tile)
    if tile == nil then
        return
    end
    local amount = game.control.encounter.getSellAmount(tile)
    local priceText = tostring(amount) .. ' G'
    local priceObject = game.object.getRoot().find('main/viewport/trash/price')
    if priceObject == nil then
        return
    end
    priceObject.getComponent('text').setText(priceText)
end

local function _tilesFullError()
    game.audio.playSound('data/sounds/general/fail.json')
    local count = game.control.tiles.getCount()
    for i=1, count do
        game.control.ui.highlightTile(i)
    end
    local function unhighlight()
        for i=1, count do
            game.control.ui.unhighlightTile(i)
        end
    end
    game.timer.queue(0.2, unhighlight)
end

local function _refreshPrices()
    if _object == nil then
        return
    end
    local rerollCost = game.control.encounter.peekRerollCost()
    _setTextPair(_object, 'rerollPrice/text', tostring(rerollCost) .. ' G')
    _setTextPair(_object, 'rerollPrice/shadow', tostring(rerollCost) .. ' G')
    for index, item in pairs(_items) do
        if item ~= nil then
            local itemPrice = game.control.encounter.getCost(index)
            _setTextPair(item, 'button/label/text', tostring(itemPrice) .. ' G')
            _setTextPair(item, 'button/label/shadow', tostring(itemPrice) .. ' G')
        end
    end
end

local function _clearItems()
    for _, dither in ipairs(_outlineDitherers) do
        dither.cancel()
    end
    _outlineDitherers = {}
    --MOD (nil fix): a tooltip left open when its item is destroyed never gets
    --its mouse-exit event, so it would stay stuck on screen.
    for _, closeTooltip in pairs(_tooltipClosers) do
        closeTooltip()
    end
    _tooltipClosers = {}
    for _, item in pairs(_items) do
        if item ~= nil then
            item.destroy()
        end
    end
    _items = {}
end

local function _createOutlineDither(object)
    local dither = dofile('data/scripts/ui/dither_fader.lua')
    dither.init(object.getComponent('mask'), 0, false)
    table.insert(_outlineDitherers, dither)
    local function fadeIn()
        local function fadeOut()
            dither.fadeTo(0, 1.0, fadeIn)
        end
        dither.fadeTo(100, 1.0, fadeOut)
    end
    fadeIn()
end

local function _destroyChild(parent, name)
    local child = parent.find(name)
    if child ~= nil then
        child.destroy()
    end
end

local function _tryPurchaseItem(index, onItemPurchase)
    --MOD (nil fix): never try to buy an empty/already bought slot
    if _items[index] == nil or game.control.encounter.getSlot(index) == nil then
        game.audio.playSound('data/sounds/general/fail.json')
        return
    end
    local success, errorCode = game.control.encounter.tryPurchase(index)
    if not success then
        if errorCode == 'tilesFull' then
            _tilesFullError()
        else
            game.audio.playSound('data/sounds/general/fail.json')
        end
        return
    end
    game.audio.playSound('data/sounds/general/purchase.json')
    local item = _items[index]
    --MOD (nil fix): the icon is destroyed below, so close its tooltip now
    local closeTooltip = _tooltipClosers[index]
    if closeTooltip ~= nil then
        closeTooltip()
    end
    if item ~= nil then
        if onItemPurchase ~= nil then
            onItemPurchase(index, item)
        end
        _destroyChild(item, 'outline')
        _destroyChild(item, 'icon')
        _destroyChild(item, 'button')
    elseif onItemPurchase ~= nil then
        onItemPurchase(index, nil)
    end
    _refreshPrices()
end

local id = 0

local function _spawnItem(index, onItemPurchase)
    local item = game.control.encounter.getSlot(index)
    if item == nil then
        return --MOD (nil fix): empty slot (nothing could be rolled), spawn nothing
    end
    local itemObject = game.object.instantiate('data/scenes/encounters/shop_item.json',
        _object.find('items'))
    --itemObject.name = tostring(index)
    id = id + 1
    itemObject.name = tostring(id)
    game.object.setVisual(itemObject.find('icon'), item.icon)
    if item.rarity == 3 then
        _theme.colorRarityImage(itemObject.find('outline/color').getComponent('image'), item.rarity)
        _createOutlineDither(itemObject.find('outline'))
    elseif item.rarity == 4 then
        _theme.colorRarityImage(itemObject.find('outline/color').getComponent('image'), item.rarity)
        _createOutlineDither(itemObject.find('outline'))
    else
        itemObject.find('outline/color').getComponent('image').setColor(0, 0, 0, 0)
    end
    local function tryPurchase()
        _tryPurchaseItem(index, onItemPurchase)
    end
    local button = dofile('data/scripts/ui/default_text_button.lua')
    button.init(itemObject.find('button'))
    itemObject.find('button/button').getComponent('button').onClick.subscribe(tryPurchase)
    local tooltip = nil
    local function displayTooltip()
        if tooltip ~= nil then
            tooltip.destroy()
        end
        tooltip = dofile('data/scripts/ui/tooltip.lua')
        tooltip.initInactive(item)
        game.control.ui.indicatePossibleCombinations(item)
    end
    local function destroyTooltip()
        if tooltip ~= nil then
            tooltip.destroy()
            tooltip = nil
        end
        game.control.ui.refreshPossibleCombinations()
    end
    itemObject.find('icon').getComponent('button').onMouseEnter.subscribe(displayTooltip)
    itemObject.find('icon').getComponent('button').onMouseExit.subscribe(destroyTooltip)
    _tooltipClosers[index] = destroyTooltip
    _items[index] = itemObject
end

function shopHelper.init(parent, refreshRates)
    _object = parent
    game.control.ui.setTrashReceiver('data/scenes/main_trash.json', _populateTrashValue, _sellItem)
    _refreshRates = refreshRates
end

function shopHelper.update()
    if _pendingRefresh then
        _pendingRefresh = false
        if _refreshRates then
            _refreshRates()
        end
    end
end

function shopHelper.destroy()
    _closeSellConfirmation()
    _clearItems()
    game.control.ui.setTrashReceiver(nil, nil, nil)
end

function shopHelper.refresh(onItemSpawn, onItemPurchase)
    _clearItems()
    local count = game.control.encounter.slots
    for i=1, count do
        _spawnItem(i, onItemPurchase)
    end
    _refreshPrices()
    local index = 1
    local function completeRefresh()
        _isRerolling = false
    end
    if count < 1 then
        completeRefresh()
        return
    end
    local function ditherNext()
        local ditherer = dofile('data/scripts/ui/staggered_dither.lua')
        local item = game.control.encounter.getSlot(index)
        local itemObject = _items[index]
        --MOD (nil fix): skip empty slots instead of crashing on item.rarity
        if item ~= nil and itemObject ~= nil then
            if item.rarity == 3 or item.rarity == 4 then
                game.audio.playSound('data/sounds/general/reroll_2.json')
            else
                game.audio.playSound('data/sounds/general/reroll_1.json')
            end
            if onItemSpawn ~= nil then
                onItemSpawn(index, item)
            end
            ditherer.queueDitherIn(itemObject.getComponent('mask'), 0)
        end
        index = index + 1
        if index <= count then
            ditherer.executeDither(ditherNext, 0.1)
        else
            ditherer.executeDither(completeRefresh, 0.1)
        end
    end
    ditherNext()
end

shopHelper.refreshPrices = _refreshPrices

function shopHelper.reroll(onPrepare, onItemSpawn, onItemPurchase)
    if _isRerolling then
        return
    end
    _isRerolling = true
    local success = game.control.encounter.tryReroll()
    if not success then
        game.audio.playSound('data/sounds/general/fail.json')
        _isRerolling = false
    else
        _clearItems()
        if onPrepare ~= nil then
            local function refresh()
                shopHelper.refresh(onItemSpawn, onItemPurchase)
            end
            onPrepare(refresh)
        else
            shopHelper.refresh(nil, nil)
        end
    end
end

function shopHelper.refreshRates(common, uncommon, rare, legendary)
    local luck = game.control.luck
    _object.find('percentages/luckAmount').getComponent('text').setText(tostring(luck))
    local commonText = _object.find('percentages/common').getComponent('text')
    _theme.colorRarityText(commonText, 1)
    local commonAmountText = _object.find('percentages/commonChance').getComponent('text')
    _theme.colorRarityText(commonAmountText, 1)
    local uncommonText = _object.find('percentages/uncommon').getComponent('text')
    _theme.colorRarityText(uncommonText, 2)
    local uncommonAmountText = _object.find('percentages/uncommonChance').getComponent('text')
    _theme.colorRarityText(uncommonAmountText, 2)
    local rareText = _object.find('percentages/rare').getComponent('text')
    _theme.colorRarityText(rareText, 3)
    local rareAmountText = _object.find('percentages/rareChance').getComponent('text')
    _theme.colorRarityText(rareAmountText, 3)
    local legendaryText = _object.find('percentages/legendary').getComponent('text')
    _theme.colorRarityText(legendaryText, 4)
    local legendaryAmountText = _object.find('percentages/legendaryChance').getComponent('text')
    _theme.colorRarityText(legendaryAmountText, 4)

    local total = common + uncommon + rare + legendary
    local cper = (common / total) * 100.0
    commonAmountText.setText(string.format('%.4g', cper) .. '%')
    local uper = (uncommon / total) * 100.0
    uncommonAmountText.setText(string.format('%.4g', uper) .. '%')
    local rper = (rare / total) * 100.0
    rareAmountText.setText(string.format('%.4g', rper) .. '%')
    local lper = (legendary / total) * 100.0
    legendaryAmountText.setText(string.format('%.4g', lper) .. '%')
end

return shopHelper
