local hotspring = {
    ui = dofile('data/scripts/ui/dialogue_encounter.lua'),
}

local _data = require('data/scripts/data.lua')
local _pendingPath = 1
local _isWashing = true

local function _hasItem()
    local itemData = _data.tiles['oni_killer']
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

local function _obtainBuff()
    game.audio.playSound('data/sounds/general/activation.json')
    game.control.buffs.add(_data.buffs['growing_strength'])
    hotspring.ui.completeEncounter()
end

local function _obtainItem()
    game.audio.playSound('data/sounds/general/activation.json')
    game.control.tiles.setFirstOpenSlot(_data.tiles['oni_killer'])
    hotspring.ui.completeEncounter()
end

local function _entryDialogue()
    hotspring.ui.setSprite('data/sprites/black.png')
    hotspring.ui.setBackground('data/sprites/black.png')
    game.audio.playSound('data/sounds/general/enter_water.json')
    if _pendingPath == 1 then
        hotspring.ui.spawnDialogue('data/dialogue/hotspring/4a.json', _obtainBuff)
    elseif _pendingPath == 2 and not game.control.tiles.isFull() and not _hasItem() then
        hotspring.ui.spawnDialogue('data/dialogue/hotspring/4b.json', _obtainItem)
    else
        hotspring.ui.spawnDialogue('data/dialogue/hotspring/4c.json', _obtainBuff)
    end
end

local function _enterBath()
    game.control.ui.fadeToBlack()
    _isWashing = false
    game.timer.queue(1.0, _entryDialogue)
end

local function _washLoop()
    local _isUp = true
    local function soundLoop()
        if not _isWashing then
            return
        end
        _isUp = not _isUp
        if _isUp then
            game.audio.playSound('data/sounds/sex/rub2_up.json')
        else
            game.audio.playSound('data/sounds/sex/rub2_down.json')
        end
        game.timer.queueScaled(1.0, soundLoop)
    end
    soundLoop()
end

local function _startWashing()
    _washLoop()
    hotspring.ui.spawnDialogue('data/dialogue/hotspring/3.json', _enterBath)
end

local function _transitionToWash()
    game.control.ui.fadeToBlack()
    local function setSprite()
        hotspring.ui.setSprite('data/sprites/encounters/hotspring_2.png')
    end
    game.timer.queue(0.5, setSprite)
    game.timer.queue(1.0, game.control.ui.fadeIn)
    game.timer.queue(1.5, _startWashing)
end

local function _spawnGirls()
    hotspring.ui.fadeSprite('data/sprites/encounters/hotspring_sprite.png')
    hotspring.ui.spawnDialogue('data/dialogue/hotspring/2.json', _transitionToWash)
end

function hotspring.init()
    hotspring.ui.init()
    game.audio.playMusic('data/sounds/water_stream.json')
    hotspring.ui.setBackground('data/sprites/encounters/hotspring_bg.png')
    hotspring.ui.setSprite('data/sprites/dither/0.png')
    hotspring.ui.spawnDialogue('data/dialogue/hotspring/1.json', _spawnGirls)
end

function hotspring.setPath(path)
    _pendingPath = path
end

function hotspring.onDestroy()
    hotspring.ui.destroy()
end

return hotspring
