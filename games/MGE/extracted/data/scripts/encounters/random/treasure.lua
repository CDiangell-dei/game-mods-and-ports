local treasure = {
    ui = dofile('data/scripts/ui/dialogue_encounter.lua'),
}

local _data = require('data/scripts/data.lua')
local _items = {
    'queen_slime',
    'black_card',
    'vampiric_slime',
    'king_crown',
    'jester_hat',
}
local _shaking = true

local function _hasItem(key)
    local itemData = _data.tiles[key]
    if itemData == nil then
        return true
    end
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile.data == itemData then
                return true
            end
        end
    end
    return false
end

local function _obtainItem()
    local roll = math.random(#_items)
    while true do
        local key = _items[roll]
        if not _hasItem(key) then
            game.control.tiles.setFirstOpenSlot(_data.tiles[key])
            return
        end
        roll = roll + 1
        if roll > #_items then
            roll = 1
        end
    end
end

local function _completeItem()
    _obtainItem()
    game.audio.playSound('data/sounds/general/activation.json')
    treasure.ui.completeEncounter()
end

local function _hasAllItems()
    for _, key in ipairs(_items) do
        if not _hasItem(key) then
            return false
        end
    end
    return true
end

local function _startChestOpen()
    if _hasAllItems() then
        treasure.ui.spawnDialogue('data/dialogue/treasure/2c.json', treasure.ui.completeEncounter)
    elseif game.control.tiles.isFull() then
        treasure.ui.spawnDialogue('data/dialogue/treasure/2b.json', treasure.ui.completeEncounter)
    else
        treasure.ui.spawnDialogue('data/dialogue/treasure/2a.json', _completeItem)
    end
end

local function _burstParticles()
    local burst = {
        burstCount = 75,
        sprite = 'data/sprites/sparkle.png',
        minPosition = {
            x = 100,
            y = 175
        },
        maxPosition = {
            x = 300,
            y = 225
        },
        minVelocity = {
            x = -25,
            y = -25
        },
        maxVelocity = {
            x = 25,
            y = 0
        },
        minAcceleration = {
            x = 0,
            y = 0
        },
        maxAcceleration = {
            x = 0,
            y = 0
        },
        minStartingSize = {
            x = 8,
            y = 8
        },
        maxStartingSize = {
            x = 12,
            y = 12
        },
        minEndingSize = {
            x = 4,
            y = 4
        },
        maxEndingSize = {
            x = 8,
            y = 8
        },
        minStartingColor = "F6DEA5",
        maxStartingColor = "FFFFFF",
        minEndingColor = "F6DEA500",
        maxEndingColor = "F6DEA500",
        minLifetime = 1,
        maxLifetime = 4,
    }
    local obj = game.object.new(game.object.getRoot().find('main/viewport'))
    local source = obj.addComponent('particleSource')
    source.spawn(burst)
end

local function _openComplete()
    _shaking = false
    _burstParticles()
    game.audio.playSound('data/sounds/general/open_chest.json')
    treasure.ui.fadeSprite('data/sprites/encounters/treasure_open.png')
    game.timer.queue(2.0, _startChestOpen)
end

local function _startShaking()
    local sprite1 = game.object.getRoot().find('main/viewport/encounter/sprite1')
    local sprite2 = game.object.getRoot().find('main/viewport/encounter/sprite2')
    local function continueShake()
        if not _shaking then
            sprite1.setPosition(0, 0)
            sprite2.setPosition(0, 0)
            return
        end
        local x = math.random(-1, 1)
        local y = math.random(-1, 1)
        sprite1.setPosition(x, y)
        sprite2.setPosition(x, y)
        game.timer.queue(0.025, continueShake)
    end
    continueShake()
end

local function _openChest()
    game.audio.playSound('data/sounds/general/sparkle.json')
    game.timer.queue(3.0, _openComplete)
    _startShaking()
end

function treasure.init()
    treasure.ui.init()
    game.audio.playMusic('data/sounds/ambient1.json')
    treasure.ui.setBackground('data/sprites/encounters/treasure_bg.png')
    treasure.ui.setSprite('data/sprites/encounters/treasure_closed.png')
    treasure.ui.spawnDialogue('data/dialogue/treasure/1.json', _openChest)
end

function treasure.onDestroy()
    treasure.ui.destroy()
end

return treasure
