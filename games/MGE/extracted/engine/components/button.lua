local button = {
    type = 'Button',
    onMouseEnter = engine.dofile('engine/event_receiver.lua'),
    onMouseExit = engine.dofile('engine/event_receiver.lua'),
    onMouseDown = engine.dofile('engine/event_receiver.lua'),
    onMouseUp = engine.dofile('engine/event_receiver.lua'),
    onClick = engine.dofile('engine/event_receiver.lua'),
}

local _persist = engine.require('engine/components/persistent_data.lua')
local _blockType = 'block'
local _isOver = false
local _mouseIsDown = false

-- MOD (touch redesign): every button, toggle and menu item in the game
-- goes through this one component, so growing its hit box a little on
-- Android (fingers are far less precise than a mouse) makes small UI
-- everywhere -- settings toggles included -- noticeably easier to hit,
-- without changing how anything looks or behaves on desktop.
local _isAndroid = love.system.getOS() == 'Android'
local _touchHitPadding = 8 --extra canvas px of forgiveness on each side, mobile only

local function _mouseIsOver()
    local x, y = engine.input.getMousePosition()
    local actualX, actualY = button.object.getActualPosition()
    local w, h = button.object.getSize()
    local padding = _isAndroid and _touchHitPadding or 0
    if x < actualX - padding or y < actualY - padding then
        return false
    end
    if x > actualX + w + padding or y > actualY + h + padding then
        return false
    end
    return true
end

local function _verifyIsActive()
    local count = #_persist.activeReceivers
    for i=1, count do
        local receiver = _persist.activeReceivers[i]
        if receiver == button then
            return true
        end
    end
    return false
end

local function _verifyMouseOver()
    local isActive = _verifyIsActive()
    if _isOver and isActive then
        return
    end
    if not _isOver and not isActive then
        return
    end
    _isOver = not _isOver
    if _isOver then
        button.onMouseEnter.invoke()
    else
        button.onMouseExit.invoke()
    end
end

local function _onMousePress(index)
    if index ~= 1 then
        return
    end
    if not _isOver then
        return
    end
    button.onMouseDown.invoke()
    _mouseIsDown = true
end

local function _onMouseRelease(index)
    if index ~= 1 then
        return
    end
    if not _mouseIsDown then
        return
    end
    button.onMouseUp.invoke()
    if _isOver then
        button.onClick.invoke()
    end
    _mouseIsDown = false
end

local function _clearReceivers()
    local count = #_persist.activeReceivers
    for i=1, count do
        _persist.activeReceivers[i] = nil
    end
end

function button.populateFromData(data)
    if type(data.blockType) == 'string'  then
        button.setBlockType(data.blockType)
    end
end

function button.update()
    if not _persist.cleared then
        _persist.cleared = true
        _clearReceivers()
    end
    if _blockType == 'ignore' then
        return
    end
    if not _mouseIsOver() then
        return
    end
    if _blockType == 'block' then
        _clearReceivers()
    end
    table.insert(_persist.activeReceivers, button)
end

function button.lateUpdate()
    _persist.cleared = false
    _verifyMouseOver()
end

function button.start()
    engine.events.subscribe('mousePressed', _onMousePress)
    engine.events.subscribe('mouseReleased', _onMouseRelease)
end

function button.onDestroy()
    engine.events.unsubscribe('mousePressed', _onMousePress)
    engine.events.unsubscribe('mouseReleased', _onMouseRelease)
    if _isOver then
        _isOver = false
        button.onMouseExit.invoke()
    end
    if _mouseIsDown then
        _mouseIsDown = false
        button.onMouseUp.invoke()
    end
    button.onMouseEnter.clear()
    button.onMouseExit.clear()
    button.onMouseDown.clear()
    button.onMouseUp.clear()
    button.onClick.clear()
end

function button.setBlockType(blockType)
    if type(blockType) ~= 'string' then
        engine.debug.logError('Type: ' .. type(blockType))
        return
    end
    _blockType = blockType
end

function button.getBlockType()
    return _blockType
end

return button