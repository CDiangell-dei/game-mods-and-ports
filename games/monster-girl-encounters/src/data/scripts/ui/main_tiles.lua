local mainTiles = {}

local _currentMouseOver = 0
local _mouseOverTrash = false
local _dragData = nil
local _theme = require('data/scripts/ui/theme.lua')
local _buttons = {}
local _tiles = {}
local _trashReceiverPrefab = nil
local _onDestroyTile = nil
local _onSpawnReceiver = nil
local _trashReceiver = nil
local _dragTile = nil
local _preventInput = false
local _inputLocked = false --MOD (shop confirm): true while a sell confirmation popup is open

-- MOD (touch redesign): touchscreens can lose the release half of a
-- press/release pair entirely (the OS can swallow it during a system
-- gesture, a focus change, etc.), which used to leave an item picked up
-- forever -- along with its trash-can receiver -- until some unrelated
-- later tap resolved the stale drag, sometimes landing on that leftover
-- trash-can and selling the item by accident. The fixes below make sure
-- a pick-up can never survive indefinitely and can never resolve twice.
local _isAndroid = love.system.getOS() == 'Android'
local _touchHitPadding = 10 --extra canvas px of forgiveness around tiles, mobile only
local _dragElapsed = 0
local _dragTimeout = 4.0 --seconds a pick-up can stay unresolved before it auto-cancels

-- MOD (touch fix): tile hover tracking (_currentMouseOver) is updated via
-- onMouseEnter/onMouseExit events, which only run once per frame during the
-- object update cycle. On touchscreens a tap can press/release a tile in the
-- same or an adjacent frame before that cycle catches up, leaving
-- _currentMouseOver pointing at a stale tile from a previous touch. This does
-- a fresh, direct hit-test against the actual tile bounds so drag start/stop
-- always uses the tile that is really under the finger right now.
local function _hitTestTile(mouseX, mouseY)
    -- MOD (touch redesign): grow each tile's hit box a little on mobile
    -- only (fingers are far less precise than a mouse pointer). Tiles are
    -- tested for the nearest center so a small overlap between padded
    -- neighboring boxes always resolves to whichever tile is actually
    -- closest to the touch point.
    local padding = _isAndroid and _touchHitPadding or 0
    local bestIndex = 0
    local bestDistance = nil
    for index, tileObject in pairs(_tiles) do
        if tileObject ~= nil then
            local x, y = tileObject.getActualPosition()
            local w, h = tileObject.getSize()
            if mouseX >= x - padding and mouseX <= x + w + padding and mouseY >= y - padding and mouseY <= y + h + padding then
                local centerX = x + w * 0.5
                local centerY = y + h * 0.5
                local distance = (mouseX - centerX) ^ 2 + (mouseY - centerY) ^ 2
                if bestDistance == nil or distance < bestDistance then
                    bestDistance = distance
                    bestIndex = index
                end
            end
        end
    end
    return bestIndex
end

local function _destroyTrashReceiver()
    if _trashReceiver ~= nil then
        _trashReceiver.destroy()
        _trashReceiver = nil
    end
    _mouseOverTrash = false
end

local function _spawnTrashReceiver(tile)
    if _trashReceiverPrefab == nil then
        return
    end
    local parent = game.object.getRoot().find('main/viewport')
    _trashReceiver = game.object.instantiate(_trashReceiverPrefab, parent)
    local function enter()
        _mouseOverTrash = true
    end
    local function exit()
        _mouseOverTrash = false
    end
    local dither = dofile('data/scripts/ui/dither_fader.lua')
    dither.init(_trashReceiver.getComponent('mask'), 0, false)
    dither.fadeTo(100, 0.2, nil)
    _trashReceiver.find('view').getComponent('button').onMouseEnter.subscribe(enter)
    _trashReceiver.find('view').getComponent('button').onMouseExit.subscribe(exit)
    if _onSpawnReceiver ~= nil then
        _onSpawnReceiver(tile)
    end
end

-- MOD (touch redesign): fully undo an in-progress pick-up (visual,
-- ghost icon, trash-can receiver, state) without swapping or selling
-- anything. Used both as a safety-net watchdog and to clean up a stale
-- drag before starting a new one, so two pick-ups can never overlap.
local function _cancelDrag()
    if _dragData == nil then
        return
    end
    local index = _dragData.index
    _dragData = nil
    _dragElapsed = 0
    if _dragTile ~= nil then
        _dragTile.destroy()
        _dragTile = nil
    end
    _destroyTrashReceiver()
    mainTiles.updateTile(index)
end

local function _startDrag(button)
    if _preventInput or _inputLocked then
        return
    end
    if button ~= 1 then
        return
    end
    -- MOD (touch redesign): a previous pick-up should always have been
    -- resolved by _stopDrag before a new press can happen. If one is
    -- still open here, its release was lost (common on touchscreens when
    -- the OS swallows the touch-up), so clean it up safely first instead
    -- of letting a second pick-up and a second trash-can receiver stack
    -- on top of it.
    if _dragData ~= nil then
        _cancelDrag()
    end
    -- MOD (touch fix): re-check which tile is actually under the touch/cursor
    -- right now instead of trusting a possibly one-frame-stale hover value.
    local pressX, pressY = game.input.getMousePosition()
    local freshTarget = _hitTestTile(pressX, pressY)
    if freshTarget ~= _currentMouseOver then
        _currentMouseOver = freshTarget
    end
    if _currentMouseOver == 0 then
        return
    end
    local tile = game.control.tiles.getTile(_currentMouseOver)
    if tile == nil then
        return
    end
    local currentTile = _tiles[_currentMouseOver]
    if currentTile == nil then
        return
    end
    _spawnTrashReceiver(tile)
    game.audio.playSound('data/sounds/general/grab.json')
    _dragTile = game.object.instantiate('data/scenes/main_tile_drag.json', game.object.getRoot().find('main'))
    game.object.setVisual(_dragTile, tile.data.icon)
    local x, y = currentTile.getActualPosition()
    _dragTile.setPosition(x + 1, y + 1) --+1 for outline width
    local mouseX, mouseY = game.input.getMousePosition()
    _dragData = {
        x = x + 1,
        y = y + 1,
        mouseX = mouseX,
        mouseY = mouseY,
        index = _currentMouseOver,
    }
    _dragElapsed = 0
    game.object.setVisual(currentTile.find('button'), 'data/sprites/dither/0.png')
    mainTiles.indicatePossibleCombinations(tile.data)
end

local function _stopDrag(button)
    if button ~= 1 then
        return
    end
    if _dragData == nil then
        return
    end
    -- MOD (touch fix): same fresh hit-test on release, so the drop target is
    -- always the tile actually under the finger at release, not a stale one.
    local releaseX, releaseY = game.input.getMousePosition()
    local freshTarget = _hitTestTile(releaseX, releaseY)
    if freshTarget ~= _currentMouseOver then
        _currentMouseOver = freshTarget
    end
    local data = _dragData
    -- MOD (touch fix): treat tiny finger jitter (a tap that barely moved) as
    -- "put it back", not a swap, even if that jitter crossed into a
    -- neighboring tile's bounds. Real mouse drags always move far more than
    -- this before release.
    local tapTolerance = 6
    local moveDistance = math.sqrt((releaseX - data.mouseX) ^ 2 + (releaseY - data.mouseY) ^ 2)
    if moveDistance < tapTolerance then
        _currentMouseOver = data.index
    end
    _dragData = nil
    if _dragTile ~= nil then
        _dragTile.destroy()
        _dragTile = nil
    end
    if _mouseOverTrash then
        -- MOD (shop confirm): the trash callback may return false to say
        -- "don't destroy now, I'll handle it" (used by the sell confirmation
        -- popup). Any other return value keeps the original behavior.
        local destroyNow = true
        if _onDestroyTile ~= nil then
            local result = _onDestroyTile(data.index)
            if result == false then
                destroyNow = false
            end
        end
        if destroyNow then
            if game.control.tiles.getTile(data.index) ~= nil then
                game.control.tiles.destroyTile(data.index)
            end
        else
            mainTiles.updateTile(data.index)
        end
    elseif _currentMouseOver ~= 0 then
        game.audio.playSound('data/sounds/general/drop.json')
        game.control.tiles.swapTile(data.index, _currentMouseOver)
    else
        game.audio.playSound('data/sounds/general/drop.json')
        mainTiles.updateTile(data.index)
    end
    _destroyTrashReceiver()
end

local function _spawnTile(index)
    local parent = game.object.getRoot().find('main/inventoryHolder/inventory/content')
    local tile = game.object.instantiate('data/scenes/main_tile.json', parent)
    tile.name = tostring(index)
    _tiles[index] = tile
    mainTiles.updateTile(index)
    local tooltip = nil
    local function enter()
        _currentMouseOver = index
        if tooltip ~= nil then
            tooltip.destroy()
        end
        if _dragData ~= nil then
            tooltip = nil
            return
        end
        tooltip = dofile('data/scripts/ui/tooltip.lua')
        local data = game.control.tiles.getTile(index)
        tooltip.initActive(data)
    end
    local function exit()
        if _currentMouseOver == index then
            _currentMouseOver = 0
        end
        if tooltip ~= nil then
            tooltip.destroy()
            tooltip = nil
        end
    end
    local button = dofile('data/scripts/ui/default_highlight_button.lua')
    button.fadeTimer = 0
    button.mouseDownSound = nil
    button.mouseoverSound = nil
    button.init(tile)
    tile.find('button').getComponent('button').onMouseEnter.subscribe(enter)
    tile.find('button').getComponent('button').onMouseExit.subscribe(exit)
    _buttons[index] = button
end

local function _stopAllIndicators()
    for _, button in pairs(_buttons) do
        button.stopIndicate()
    end
end

local function _addCombination(index1, index2, activeCombinations)
    local button1 = _buttons[index1]
    if button1 ~= nil then
        button1.indicate()
    end
    local button2 = _buttons[index2]
    if button2 ~= nil then
        button2.indicate()
    end
    activeCombinations[index1] = 1
    activeCombinations[index2] = 1
end

local function _showCombinationVisuals(combination)
    local tile1Object = _tiles[combination.index1]
    local tile2Object = _tiles[combination.index2]
    if tile1Object == nil or tile2Object == nil then
        return
    end
    local x1, y1 = tile1Object.getActualPosition()

    local parent = game.object.getRoot().find('main')
    local tile2 = game.object.instantiate('data/scenes/main_tile_drag.json', parent)
    local tile2Actual = game.control.tiles.getTile(combination.index2)
    if tile2Actual ~= nil then
        game.object.setVisual(tile2, tile2Actual.data.icon)
    end
    local x2, y2 = tile2Object.getActualPosition()
    tile2.setPosition(x2 + 1, y2 + 1)

    game.object.setVisual(tile2Object.find('button'), 'data/sprites/dither/0.png')

    local flash = game.object.instantiate('data/scenes/tile_flash.json', parent)
    flash.setPosition(x1, y1)

    local function destroyFlash()
        flash.destroy()
    end

    local function cleanup()
        tile2.destroy()
        game.timer.queue(1.0, destroyFlash)
    end
    local tween = dofile('data/scripts/ui/tween.lua')
    tween.init(tile2)
    local xGoal = x1 - x2
    local yGoal = y1 - y2
    tween.tweenPositionRelative(xGoal, yGoal, 1.0, cleanup, 'linear')
end

local _activeTiles = {}
local _pendingSuper = false

local function _updateTemporaryHighlights(dt)
    if _pendingSuper then
        _pendingSuper = false
        game.audio.playSound('data/sounds/general/tile_super.json')
    end
    local count = #_activeTiles
    for i=count, 1, -1 do
        local v = _activeTiles[i]
        v.time = v.time - dt
        if v.time <= 0 then
            v.button.deselect()
            table.remove(_activeTiles, i)
        end
    end
end

function mainTiles.setInputLocked(locked)
    _inputLocked = (locked == true)
end

function mainTiles.destroy()
    _inputLocked = false
    _stopAllIndicators()
    _destroyTrashReceiver()
    game.events.unsubscribe('mousePressed', _startDrag)
    game.events.unsubscribe('mouseReleased', _stopDrag)
end

function mainTiles.update(dt)
    _updateTemporaryHighlights(dt)
    if _dragData == nil or _dragTile == nil then
        return
    end
    -- MOD (touch redesign): safety-net watchdog. If a pick-up is never
    -- resolved (its release event lost by the OS), auto-cancel it after
    -- a few seconds instead of leaving it -- and its trash-can receiver
    -- -- on screen indefinitely waiting for an unrelated tap to resolve it.
    _dragElapsed = _dragElapsed + dt
    if _dragElapsed >= _dragTimeout then
        _cancelDrag()
        return
    end
    local mouseX, mouseY = game.input.getMousePosition()
    local xDifference = mouseX - _dragData.mouseX
    local yDifference = mouseY - _dragData.mouseY
    local x = _dragData.x + xDifference
    local y = _dragData.y + yDifference
    _dragTile.setPosition(x, y)
end

function mainTiles.setTrashReceiver(prefab, onSpawnReceiver, onDestroyTile)
    _trashReceiverPrefab = prefab
    _onSpawnReceiver = onSpawnReceiver
    _onDestroyTile = onDestroyTile
    _destroyTrashReceiver()
end

function mainTiles.updateTile(index)
    local tile = game.control.tiles.getTile(index)
    local tileObject = _tiles[index]
    if tileObject == nil then
        return
    end
    if tile == nil then
        game.object.setVisual(tileObject.find('button'), 'data/sprites/dither/0.png')
        tileObject.find('mouseDown/shape/color').getComponent('image').setColor(0, 0, 0, 0)
    else
        game.object.setVisual(tileObject.find('button'), tile.data.icon)
        _theme.colorRarityImage(tileObject.find('mouseDown/shape/color').getComponent('image'), tile.data.rarity)
    end
    _stopDrag(1)
    mainTiles.refreshPossibleCombinations()
end

function mainTiles.highlightTile(index)
    local button = _buttons[index]
    if button == nil then
        return
    end
    button.select()
end

function mainTiles.triggerHighlightTile(index, playSuper)
    local button = _buttons[index]
    if button == nil then
        return
    end
    button.select()
    local temp = {
        button = button,
        time = 0.25,
    }
    table.insert(_activeTiles, temp)
    if playSuper then
        _pendingSuper = true
    end
end

function mainTiles.spawnTileOrb(index)
    --[[
    local tileObject = _tiles[index]
    if tileObject == nil then
        return
    end
    local x, y = tileObject.getActualPosition()
    local orb = dofile('data/scripts/ui/pump_orb.lua')
    orb.init(x, y)
    ]]--
end

function mainTiles.unhighlightTile(index)
    local button = _buttons[index]
    if button == nil then
        return
    end
    button.deselect()
end

function mainTiles.indicatePossibleCombinations(data)
    _stopAllIndicators()
    if data.combination == nil then
        return
    end
    local count = game.control.tiles.getCount()
    for i=1, count do
        local tile = game.control.tiles.getTile(i)
        if tile ~= nil and game.control.tiles.canCombine(data, tile.data) then
            local button = _buttons[i]
            if button ~= nil then
                button.indicate()
            end
        end
    end
end

function mainTiles.refreshPossibleCombinations()
    _stopAllIndicators()
    --indicate imminent combinations only
    local activeCombinations = {}
    local count = game.control.tiles.getCount()
    for i=count, 1, -1 do
        local tile = game.control.tiles.getTile(i)
        if tile ~= nil and activeCombinations[i] == nil then
            local hasCombination, combinedIndex = game.control.tiles.findImminentCombination(i)
            if hasCombination then
                _addCombination(i, combinedIndex, activeCombinations)
            end
        end
    end
end

function mainTiles.combineTiles(combinations, onComplete)
    _preventInput = true
    _stopAllIndicators()
    _stopDrag(1)
    for _, combination in pairs(combinations) do
        _showCombinationVisuals(combination)
    end
    game.audio.playSound('data/sounds/general/consume.json')
    local function completeCombination()
        game.audio.playSound('data/sounds/general/tile_super.json')
        _preventInput = false
        onComplete()
    end
    game.timer.queue(1.0, completeCombination)
end

function mainTiles.refreshTiles()
    for _, tile in pairs(_tiles) do
        tile.destroy()
    end
    _tiles = {}
    local count = game.control.tiles.getCount()
    for i=1, count do
        _spawnTile(i)
    end
    mainTiles.refreshPossibleCombinations()
end

function mainTiles.init()
    game.events.subscribe('mousePressed', _startDrag)
    game.events.subscribe('mouseReleased', _stopDrag)
    mainTiles.refreshTiles()
end

return mainTiles
