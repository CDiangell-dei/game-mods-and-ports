local selectorUI = {}

local _selector
local _active = nil
local _object

local function _clear()
    if _active ~= nil then
        _active.destroy()
        _active = nil
    end
end

function selectorUI.instantiate(selector)
    _selector = selector
    _object = game.object.instantiate('data/scenes/selection.json')
end

function selectorUI.destroy()
    _clear()
    if _object == nil then
        return
    end
    _object.destroy()
    _object = nil
end

function selectorUI.enterModeSelection()
    _clear()
    _active = dofile('data/scripts/ui/mode_selector.lua')
    _active.instantiate(_selector)
end

-- MOD (save/continue): "continue or new run" screen
function selectorUI.enterRunChoice()
    _clear()
    _active = dofile('data/scripts/ui/run_choice.lua')
    _active.instantiate(_selector)
end

function selectorUI.enterItemSelection()
    _clear()
    _active = dofile('data/scripts/ui/item_selector.lua')
    _active.instantiate(_selector)
end

function selectorUI.fadeIn()
    if _active ~= nil then
        _active.fadeIn()
    end
end

function selectorUI.addItem(item)
    if _active ~= nil then
        _active.addItem(item)
    end
end

return selectorUI