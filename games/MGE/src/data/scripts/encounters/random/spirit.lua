local spirit = {
    ui = dofile('data/scripts/ui/dialogue_encounter.lua'),
}

local _data = require('data/scripts/data.lua')
local _pendingPath = 1
local _isFucking = true

local function _hasItem()
    local itemData = _data.tiles['ectoplasmic_slime']
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
    game.control.buffs.add(_data.buffs['shadowed_backpack'])
    spirit.ui.completeEncounter()
end

local function _obtainItem()
    game.audio.playSound('data/sounds/general/activation.json')
    game.control.tiles.setFirstOpenSlot(_data.tiles['ectoplasmic_slime'])
    spirit.ui.completeEncounter()
end

local function _makeChoice()
    if _pendingPath == 2 then
        spirit.ui.spawnDialogue('data/dialogue/spirit_girl/6c.json', _obtainBuff)
    elseif _pendingPath == 1 and not game.control.tiles.isFull() and not _hasItem() then
        spirit.ui.spawnDialogue('data/dialogue/spirit_girl/6a.json', _obtainItem)
    else
        spirit.ui.spawnDialogue('data/dialogue/spirit_girl/6b.json', _obtainBuff)
    end
end

local function _wakeUp()
    _isFucking = false
    spirit.ui.setBackground('data/sprites/encounters/spirit_girl_4.png')
    local function nextDialogue()
        spirit.ui.spawnDialogue('data/dialogue/spirit_girl/5.json', _makeChoice)
    end
    game.timer.queue(1.0, game.control.ui.fadeIn)
    game.timer.queue(1.5, nextDialogue)
end

local function _blackout()
    game.control.ui.fadeToBlack()
    game.timer.queue(2.0, _wakeUp)
end

local function _cum()
    dofile('data/scripts/general/cum_outside.lua')
    local function setCumSprite()
        spirit.ui.setBackground('data/sprites/encounters/spirit_girl_3.png')
    end
    game.timer.queue(0.25, setCumSprite)
    local function nextDialogue()
        spirit.ui.spawnDialogue('data/dialogue/spirit_girl/4.json', _blackout)
    end
    game.timer.queue(2.0, nextDialogue)
end

local function _wakeDream2()
    spirit.ui.spawnDialogue('data/dialogue/spirit_girl/3.json', _cum)
end

local function _wakeDream()
    game.control.ui.fadeIn()
    game.timer.queue(0.5, _wakeDream2)
end

local function _partialWake()
    spirit.ui.setBackground('data/sprites/encounters/spirit_girl_2.png')
    spirit.ui.spawnDialogue('data/dialogue/spirit_girl/2.json', _wakeDream)
end

local function _goSleep()
    game.control.ui.fadeToBlack()
    game.timer.queue(1.0, _partialWake)
end

local function _sexSounds()
    local _isUp = true
    local function soundLoop()
        if not _isFucking then
            return
        end
        _isUp = not _isUp
        if _isUp then
            game.audio.playSound('data/sounds/sex/rub_up.json')
        else
            game.audio.playSound('data/sounds/sex/rub_down.json')
        end
        game.timer.queueScaled(1.0, soundLoop)
    end
    soundLoop()
end

function spirit.init()
    spirit.ui.init()
    game.audio.playMusic('data/sounds/ambient1.json')
    spirit.ui.setBackground('data/sprites/encounters/spirit_girl_1.png')
    spirit.ui.setSprite('data/sprites/dither/0.png')
    spirit.ui.spawnDialogue('data/dialogue/spirit_girl/1.json', _goSleep)
end

function spirit.setPath(path)
    if path == -1 then
        _sexSounds()
        return
    end
    _pendingPath = path
end

function spirit.onDestroy()
    spirit.ui.destroy()
end

return spirit
