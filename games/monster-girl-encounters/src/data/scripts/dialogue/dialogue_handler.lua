local dialogueHandler = { }

local _mods = require('mods/mod_manager.lua') -- MOD

local _state = nil
local _onComplete
local _dialogue
local _activeTarget = nil
local _autoProgress = true

local function _completeCallback()
    local onComplete = _onComplete
    dialogueHandler.close()
    if onComplete ~= nil then
        onComplete()
    end
end

local function _loadChunk(chunk)
    if chunk.type == 'choice' then
        _state = dofile('data/scripts/dialogue/dialogue_choice.lua')
        _state.init(_activeTarget, chunk, _autoProgress)
    else
        _state = dofile('data/scripts/dialogue/dialogue_text.lua')
        _state.init(_activeTarget, chunk, _autoProgress)
    end
end

local function _loadChunkFromId(id)
    for _, chunk in ipairs(_dialogue) do
        if chunk.id == id then
            _loadChunk(chunk)
            return
        end
    end
    _completeCallback()
end

local function _enterState(id)
    if id ~= nil and id > 0 then
        _loadChunkFromId(id)
    else
        _completeCallback()
    end
end

local function _update()
    if _state == nil then
        return
    end
    local next = _state.update()
    if next == 0 or _state == nil then
        return
    end
    _state.destroy()
    _state = nil
    _enterState(next)
end

function dialogueHandler.talk(target, key, onComplete, isAuto)
    if isAuto == nil then
        _autoProgress = true
    else
        _autoProgress = isAuto
    end
    -- MOD: mods can force the automatic mode used by battle dialogues (auto_skip_dialog)
    _autoProgress = _mods.filter('dialogueAutoProgress', _autoProgress)
    dialogueHandler.close()
    _activeTarget = target
    _onComplete = onComplete
    _dialogue = game.data.loadJson(key)
    if _dialogue == nil then
        game.debug.logWarning('Could not find dialogue with key: ' .. tostring(key))
        _completeCallback()
        return
    end
    _loadChunk(_dialogue[1])
end

function dialogueHandler.close()
    if _activeTarget == nil then
        return
    end
    if _state ~= nil then
        _state.destroy()
    end
    _state = nil
    _onComplete = nil
end

function dialogueHandler.progress()
    if _state ~= nil then
        _state.progress()
    end
end

game.events.subscribe('update', _update)

return dialogueHandler
