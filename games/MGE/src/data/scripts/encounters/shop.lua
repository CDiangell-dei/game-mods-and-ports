local shop = {
    costModifier = 1.0,
    rerollCostModifier = 1.0,
    freeRerolls = 0,
    slots = 3,
}

local _slots = {}
local _rerolls = 0

local function _refreshShop()
    --MOD (nil fix): usedItems is now an array of keys. The shop script reads it
    --with #usedItems, which is always 0 for a key->value table, so the same
    --item could show up in several slots at once.
    local usedItems = {}
    for i=1, shop.slots do
        local itemData = shop.script.getRandomItem(usedItems)
        if itemData == nil then
            --nothing left that is not already on sale: allow a repeat rather than a hole
            itemData = shop.script.getRandomItem({})
        end
        --nil here means the pool is empty: the slot stays empty (the UI skips it)
        _slots[i] = itemData
        if itemData ~= nil and itemData.key ~= nil then
            table.insert(usedItems, itemData.key)
        end
    end
end

local function _isShopEmpty()
    for i=1, shop.slots do
        if _slots[i] ~= nil then
            return false
        end
    end
    return true
end

local function _getSoldItemValue(tile)
    if tile == nil then
        return 0
    end
    local baseValue = tile.value or 0
    if baseValue == 0 then
        return 0
    end
    baseValue = baseValue * shop.costModifier
    baseValue = math.floor(baseValue + 0.5)
    baseValue = math.max(1, baseValue)
    return baseValue
end

function shop.init()
    _refreshShop()
    shop.script.onIntro(game.control.completeEncounter)
end

function shop.onDestroy()
    shop.script.onDestroy()
end

function shop.tryReroll()
    local cost = shop.peekRerollCost()
    if game.control.getGold() < cost then
        return false
    end
    --MOD (nil fix): the free reroll is only spent here, when a reroll really happens
    if shop.freeRerolls > 0 and not _isShopEmpty() then
        shop.freeRerolls = shop.freeRerolls - 1
    end
    game.control.loseGold(cost)
    _refreshShop()
    game.control.trigger('onRerollShop', cost)
    _rerolls = _rerolls + 1
    return true
end

function shop.getSlot(index)
    return _slots[index]
end

function shop.tryPurchase(index)
    local data = _slots[index]
    if data == nil then
        return false, 'soldOut' --MOD (nil fix): empty or already bought slot
    end
    local cost = shop.getCost(index)
    if game.control.getGold() < cost then
        return false, 'notEnoughGold'
    end
    if game.control.tiles.isFull() then
        return false, 'tilesFull'
    end
    --MOD (nil fix): the holder refuses items that hit their limit; check before
    --charging, otherwise the gold was spent and no item was delivered.
    if game.control.tiles.isAtLimit ~= nil and game.control.tiles.isAtLimit(data) then
        return false, 'limitReached'
    end
    game.control.loseGold(cost)
    game.control.tiles.setFirstOpenSlot(data)
    game.control.trigger('onPurchase', data, cost)
    _slots[index] = nil
    return true
end

function shop.sellItem(tile)
    if tile == nil then
        return
    end
    local value = _getSoldItemValue(tile)
    game.control.gainGold(value)
    game.control.trigger('onSellTile', value)
end

function shop.getSellAmount(tile)
    return _getSoldItemValue(tile)
end

function shop.getCost(index)
    if _slots[index] == nil then
        return 0
    end
    if shop.costModifier < 0 then
        return 0
    end
    local value = _slots[index].value or 0
    value = value * shop.costModifier
    value = math.floor(value + 0.5)
    value = math.max(1, value)
    return value
end

function shop.getRerollCost()
    return shop.peekRerollCost()
end

--MOD (nil fix): read-only price. The old getRerollCost() spent a free reroll
--every time it was called (also when only drawing the price label).
function shop.peekRerollCost()
    if _isShopEmpty() then
        return 0
    end
    if shop.freeRerolls > 0 then
        return 0
    end
    local cost = 1.0 + _rerolls
    cost = cost * shop.rerollCostModifier
    cost = math.floor(cost + 0.5)
    cost = math.max(0, cost)
    return cost
end

function shop.increaseCostModifier(amount)
    shop.costModifier = shop.costModifier + amount
    shop.script.refreshPrices()
end

function shop.increaseRerollModifier(amount)
    shop.rerollCostModifier = shop.rerollCostModifier + amount
    shop.script.refreshPrices()
end

return shop
