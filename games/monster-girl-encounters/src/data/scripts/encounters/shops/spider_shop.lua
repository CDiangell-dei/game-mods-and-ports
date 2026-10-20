local spiderShop = {}

local _roller = dofile('data/scripts/encounters/shop_roller.lua')
local _helper = dofile('data/scripts/ui/shop_helper.lua')
local _modifiers = {
    excludedSpecific = {
        'rock',
        'boulder',
        'broken_doll',
        'bone',
        'gravel',
    }
}
local _object = nil
local _purchaseCount = 0
local _hasRerolled = false
local _isClosing = false

local function _spawnObject()
    local parent = game.object.getRoot().find('main/viewport')
    _object = game.object.instantiate('data/scenes/encounters/shop.json', parent)
    return _object
end

local function _setInitialSprites(object)
    game.object.setVisual(object.find('background'), 'data/sprites/encounters/shop_bg.png')
    game.object.setVisual(object.find('sprite'), 'data/sprites/encounters/shop_sprite.png')
    game.object.setVisual(object.find('rerollVisual'), 'data/sprites/encounters/shop_reroll_idle.png')
end

local function _setRerollButton(object)
    local rerollButton = object.find('rerollButton').getComponent('button')
    local rerollVisual = object.find('rerollVisual').getComponent('image')
    local function enterReroll()
        rerollVisual.setColor(1, 1, 1, 1)
    end
    local function exitReroll()
        rerollVisual.setColor(0.8588, 0.8431, 0.8549, 1)
    end
    rerollButton.onMouseEnter.subscribe(enterReroll)
    rerollButton.onMouseExit.subscribe(exitReroll)
    exitReroll()
end

local function _setExitButton(object)
    local exitButton = object.find('exitButton').getComponent('button')
    local exitVisual = object.find('exitButton').getComponent('image')
    local function enter()
        exitVisual.setColor(1, 1, 1, 1)
    end
    local function exit()
        exitVisual.setColor(0.8588, 0.8431, 0.8549, 1)
    end
    exitButton.onMouseEnter.subscribe(enter)
    exitButton.onMouseExit.subscribe(exit)
    exit()
end

local function _updatePersistentData()
    if game.control.persistent.shopVisitCount == nil then
        game.control.persistent.shopVisitCount = 0
    end
    game.control.persistent.shopVisitCount = game.control.persistent.shopVisitCount + 1
end

local function _spawnWelcomeDialogue()
    if game.control.persistent.shopVisitCount > 1 then
        game.control.ui.spawnDialogue('data/dialogue/shop_1/welcome_back.json', nil, true)
    else
        game.control.ui.spawnDialogue('data/dialogue/shop_1/welcome.json', nil, true)
    end
end

local function _spawnPurchaseDialogue()
    _purchaseCount = _purchaseCount + 1
    if _purchaseCount == 1 then
        game.control.ui.spawnDialogue('data/dialogue/shop_1/thank.json', nil, true)
    elseif _purchaseCount == 4 then
        game.control.ui.spawnDialogue('data/dialogue/shop_1/wow.json', nil, true)
    end
end

local function _spawnItemRollDialogue(quality)
    if quality == 3 then
        game.control.ui.spawnDialogue('data/dialogue/shop_1/rare.json', nil, true)
    elseif quality == 4 then
        game.control.ui.spawnDialogue('data/dialogue/shop_1/very_rare.json', nil, true)
    end
end

local function _spawnRerollDialogue()
    if _hasRerolled then
        return
    end
    game.control.ui.spawnDialogue('data/dialogue/shop_1/plenty.json', nil, true)
    _hasRerolled = true
end

local function _animateReroll(onComplete)
    if _object == nil then
        onComplete()
        return
    end
    game.object.setVisual(_object.find('rerollVisual'), 'data/sprites/encounters/shop_reroll_active.png')
    local function moveUp()
        game.object.setVisual(_object.find('rerollVisual'), 'data/sprites/encounters/shop_reroll_idle.png')
        onComplete()
    end
    game.audio.playSound('data/sounds/general/reroll.json')
    game.timer.queue(0.5, moveUp)
end

local function _prepareReroll(onComplete)
    _spawnRerollDialogue()
    _animateReroll(onComplete)
end

local function _processItemSpawn(_, item)
    if item == nil then
        return --MOD (nil fix)
    end
    _spawnItemRollDialogue(item.rarity)
end

local function _getRarityWeights()
    local commonWeight = _roller.getCommonWeight()
    local uncommonWeight = _roller.getUncommonWeight()
    local rareWeight = _roller.getRareWeight()
    local legendaryWeight = _roller.getLegendaryWeight()
    return commonWeight, uncommonWeight, rareWeight, legendaryWeight
end

local function _refreshRates()
    local c, u, r, l = _getRarityWeights()
    _helper.refreshRates(c, u, r, l)
end

local function _processItemPurchase(_, _)
    _refreshRates()
    _spawnPurchaseDialogue()
end

local function _subscribeRerollButton()
    if _object == nil then
        return
    end
    local rerollButton = _object.find('rerollButton').getComponent('button')
    local function reroll()
        if _isClosing then
            return
        end
        _helper.reroll(_prepareReroll, _processItemSpawn, _processItemPurchase)
        _refreshRates()
    end
    rerollButton.onClick.subscribe(reroll)
    _refreshRates()
end

local function _subscribeExitButton(onComplete)
    if _object == nil then
        return
    end
    local exitButton = _object.find('exitButton').getComponent('button')
    local function close()
        if _isClosing then
            return
        end
        _isClosing = true
        game.control.ui.fadeToTransition(onComplete)
    end
    exitButton.onClick.subscribe(close)
end

local function _completeIntro(onComplete)
    game.audio.playMusic("data/sounds/shop1.json")
    _subscribeRerollButton()
    _subscribeExitButton(onComplete)
    _helper.refresh(_processItemSpawn, _processItemPurchase)
end

local function _runIntroSequence(onComplete)
    local function completeIntro()
        _completeIntro(onComplete)
    end
    _animateReroll(completeIntro)
end

function spiderShop.onIntro(onComplete)
    _updatePersistentData()
    local object = _spawnObject()
    _helper.init(object, _refreshRates)
    _setRerollButton(object)
    _setExitButton(object)
    _setInitialSprites(object)
    _spawnWelcomeDialogue()
    local function runIntro()
        _runIntroSequence(onComplete)
    end
    game.timer.queue(1.0, runIntro)
    game.control.ui.fadeIn(nil)
    _refreshRates()
end

function spiderShop.onDestroy()
    _helper.destroy()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
end

function spiderShop.update(_)
    _helper.update()
end

function spiderShop.getRandomItem(usedItems)
    usedItems = usedItems or {} --MOD (nil fix)
    local added = 0
    for i=1, #usedItems do
        if usedItems[i] ~= nil then
            table.insert(_modifiers.excludedSpecific, usedItems[i])
            added = added + 1
        end
    end
    local data = _roller.getRandomItem(_modifiers)
    --remove temporary exclusions (exactly as many as were added above)
    for _=1, added do
        table.remove(_modifiers.excludedSpecific, #_modifiers.excludedSpecific)
    end
    return data
end

spiderShop.refreshPrices = _helper.refreshPrices

return spiderShop
