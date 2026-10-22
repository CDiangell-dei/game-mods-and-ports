local battleRewarder = {}

local _totalAmount
local _totalTime = 0
local _onComplete
local _currentTime = 0
local _initialSound
local _isClosed = false
local _hasCompleted = false
local _takeButton
local _itemReward = nil
local _object
local _text
local _shadowText

local function _setAmountText(amount)
    local str = string.format('%.5g', amount)
    _text.setText(tostring(str) .. ' G')
    _shadowText.setText(tostring(str) .. ' G')
end

local function _activateItem()
    if _itemReward == nil then
        return
    end
    local tooltip = nil
    local function displayTooltip()
        if tooltip ~= nil then
            tooltip.destroy()
        end
        tooltip = dofile('data/scripts/ui/tooltip.lua')
        tooltip.initInactive(_itemReward)
    end
    local function destroyTooltip()
        if tooltip ~= nil then
            tooltip.destroy()
            tooltip = nil
        end
    end
    local itemSprite = _object.find('itemSprite/sprite').getComponent('button')
    itemSprite.onMouseEnter.subscribe(displayTooltip)
    itemSprite.onMouseExit.subscribe(destroyTooltip)
    game.object.setVisual(_object.find('itemSprite/sprite'), _itemReward.icon)
    local fader = dofile('data/scripts/ui/dither_fader.lua')
    fader.init(_object.find('itemSprite').getComponent('mask'), 0, false)
    fader.fadeTo(100, 0.5, nil)
end

local function _completeIteration()
    _hasCompleted = true
    if _initialSound ~= nil then
        _initialSound.stop()
        _initialSound = nil
    end
    game.audio.playSound('data/sounds/general/tile_super.json')
    _activateItem()
    _takeButton.activate()
end

local function _iterateImmediate()
    if _hasCompleted then
        return
    end
    _currentTime = _totalTime
    _setAmountText(_totalAmount)
    _completeIteration()
end

local function _close()
    if _isClosed then
        return
    end
    if _initialSound ~= nil then
        _initialSound.stop()
        _initialSound = nil
    end
    _isClosed = true
    local function complete()
        if _object ~= nil then
            _object.destroy()
            _object = nil
        end
        if _itemReward ~= nil then
            game.control.tiles.setFirstOpenSlot(_itemReward)
        end
        _onComplete()
    end
    local fader = dofile('data/scripts/ui/dither_fader.lua')
    fader.init(_object.getComponent('mask'), 100, false)
    fader.fadeTo(0, 0.5, nil)
    game.control.ui.fadeToTransition(complete)
end

function battleRewarder.instantiate(amount, item, onComplete)
    _totalAmount = amount
    _onComplete = onComplete
    _totalTime = amount / 20.0
    _totalTime = math.max(2.0, _totalTime)
    _totalTime = math.min(5.0, _totalTime)
    _initialSound = game.audio.playSound('data/sounds/general/reward_loop.json')
    local parent = game.object.getRoot().find('main')
    _object = game.object.instantiate('data/scenes/encounters/gold_popup.json', parent)
    local background = _object.find('background').getComponent('button')

    if item ~= nil and not game.control.tiles.isFull() then
        _itemReward = item
    end

    _text = _object.find('earnings/text').getComponent('text')
    _shadowText = _object.find('earnings/shadow').getComponent('text')

    local takeButtonObject = _object.find('takeButton')
    _takeButton = dofile('data/scripts/ui/default_text_button.lua')
    _takeButton.init(takeButtonObject)
    _takeButton.deactivate()

    local fader = dofile('data/scripts/ui/dither_fader.lua')
    fader.init(_object.getComponent('mask'), 0, false)
    local function subscribe()
        background.onClick.subscribe(_iterateImmediate)
        takeButtonObject.find('button').getComponent('button').onClick.subscribe(_close)
    end
    fader.fadeTo(100, 0.5, subscribe)
    
end

function battleRewarder.update(deltaTime)
    if _hasCompleted then
        return
    end
    if _currentTime >= _totalTime then
        return
    end
    _currentTime = _currentTime + deltaTime
    local amount
    if _currentTime >= _totalTime then
        amount = _totalAmount
    else
        amount = (_currentTime / _totalTime) * _totalAmount
        amount = math.floor(amount)
    end
    _setAmountText(amount)
    if _currentTime >= _totalTime then
        _completeIteration()
    end
end

return battleRewarder
