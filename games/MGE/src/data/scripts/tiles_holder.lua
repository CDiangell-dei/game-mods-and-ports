local tilesHolder = {}

local _holder = dofile('data/scripts/object_holder.lua')
local _width = 4
local _height = 4
local _virtualHeight = 4
local _overfillCount = 0
local _restoring = false -- MOD (save/continue): true while a saved run is being rebuilt

local function _updateInventorySizeIndicator()
    local count = _holder.count()
    local current = 0
    for i=1, count do
        local tile = _holder.get(i)
        if tile ~= nil then
            current = current + 1
        end
    end
    game.control.ui.setInventorySize(current, _width * _height)
end

local function _setTileToIndex(index, tileData)
    if tileData == nil then
        game.debug.logError('Could not add tile, supplied data is nil.')
        return
    end
    local tile = dofile(tileData.script)
    tile.data = tileData
    tile.index = index
    tile.value = tileData.value or 0
    tile.value = tile.value * 0.5
    tile.subtype = tileData.subtype
    _holder.set(index, tile)
    game.control.trigger('onAddTile', tile)
    game.control.ui.updateTile(index)
    game.control.trigger('onInventoryChange')
    _updateInventorySizeIndicator()
    tile._ready = true
    if tile.init ~= nil then
        tile.init()
    end
end

local function _removeExcessSlots()
    local start = ((_height) * _width) + 1
    local maximum = (_height + 1) * _width
    local current = start
    for _=start, maximum do
        local tile = _holder.get(current)
        if tile == nil then
            _holder.remove(current)
        else
            _overfillCount = _overfillCount + 1
            tile.index = current
            current = current + 1
        end
    end
end

local function _moveExcessTiles()
    local maximum = (_height + 1) * _width
    local reduced = 0
    for i=maximum, 1, -1 do
        if reduced >= _width then
            return
        end
        local tile = _holder.get(i)
        if tile == nil then
            reduced = reduced + 1
            for j = i + 1, maximum do
                local movedTile = _holder.get(j)
                _holder.set(j - 1, movedTile)
                _holder.set(j, nil)
            end
        end
    end
end

local function _destroyTile(tile, stopNotification)
    tile._ready = false
    if stopNotification ~= true then
        game.control.trigger('onRemoveTile', tile)
    end
    if tile.onDestroy ~= nil then
        tile.onDestroy()
    end
    tile.index = 0
end

local function _obtainTile(data)
    local obtained = game.data.getProgress('obtained_' .. data.key)
    if obtained ~= 1 then
        game.control.trigger('onObtainNewItem')
    end
    game.data.setProgress('obtained_' .. data.key, 1)
end

local function _isAtLimit(data)
    local remaining = data.limit or 0
    if remaining <= 0 then
        return false
    end
    for y=1, _height do
        for x=1, _width do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile.data == data then
                remaining = remaining - 1
                if remaining <= 0 then
                    return true
                end
            end
        end
    end
    return false
end

--function tilesHolder.init() end

function tilesHolder.getCoordinate(index)
    if index < 1 or index > _holder.count() then
        return -1, -1
    end
    local x = index % _width
    if x == 0 then
        x = _width
    end
    local y = 1 + ((index - x) / _width)
    y = math.floor(y)
    return x, y
end

function tilesHolder.getIndex(x, y)
    if x > _width or x < 1 then
        return -1
    end
    local index = x + ((y - 1) * _width)
    if index > _holder.count() or index < 1 then
        return -1
    end
    return index
end

function tilesHolder.trigger(eventId, ...)
    _holder.trigger(eventId, ...)
end

function tilesHolder.getHeight()
    if _overfillCount > 0 then
        return _height + math.floor(_overfillCount / _width) + 1
    end
    return _height
end

function tilesHolder.getWidth()
    return _width
end

function tilesHolder.getCount()
    return _holder.count()
end

function tilesHolder.addRow()
    if _restoring then
        return --MOD (save/continue): the saved shape is applied by restoreSnapshot
    end
    _virtualHeight = _virtualHeight + 1
    if _virtualHeight > 11 or _virtualHeight < 2 then
        return
    end
    _height = _height + 1
    local additionalTileCount = _width
    if _overfillCount > 0 then
        additionalTileCount = additionalTileCount - _overfillCount
        if additionalTileCount < 0 then
            _overfillCount = -additionalTileCount
            additionalTileCount = 0
        else
            _overfillCount = 0
        end
    end
    for _=1, additionalTileCount do
        _holder.add(nil)
    end
    game.control.ui.refreshTiles()
    _updateInventorySizeIndicator()
    game.control.trigger('onInventoryChange')
end

function tilesHolder.removeRow()
    if _restoring then
        return --MOD (save/continue)
    end
    _virtualHeight = _virtualHeight - 1
    if _height == 1 then
        return
    end
    if _virtualHeight >= _height then
        return
    end
    _height = _height - 1
    if _overfillCount > 0 then
        _overfillCount = _overfillCount + _width
    else
        local start = (_height * _width) + 1
        _moveExcessTiles(start)
        _removeExcessSlots(start)
    end
    game.control.ui.refreshTiles()
    _updateInventorySizeIndicator()
    game.control.trigger('onInventoryChange')
end

--MOD (nil fix): lets other scripts ask whether a tile is at its max allowed amount
function tilesHolder.isAtLimit(tileData)
    if tileData == nil then
        return false
    end
    return _isAtLimit(tileData)
end

function tilesHolder.setFirstOpenSlot(tileData)
    if tilesHolder.isFull() then
        game.debug.logWarning('Could not add tile, holder is full.')
        return false
    end
    if _isAtLimit(tileData) then
        game.debug.logWarning('Tile data at max allowed.')
        return false;
    end
    local count = _holder.count()
    for i=1, count do
        local tile = _holder.get(i)
        if tile == nil then
            _setTileToIndex(i, tileData)
            _obtainTile(tileData)
            return true
        end
    end
end

function tilesHolder.setTile(index, tileData)
    if _isAtLimit(tileData) then
        game.debug.logWarning('Tile data at max allowed.')
        return;
    end
    local currentTile = tilesHolder.getTile(index)
    if currentTile ~= nil then
        --destroy without changing overfill
        _destroyTile(currentTile, true)
        _holder.set(index, nil)
    end
    _setTileToIndex(index, tileData)
    _obtainTile(tileData)
end

function tilesHolder.destroyTile(index, stopNotification)
    local tile = tilesHolder.getTile(index)
    if tile == nil then
        game.debug.logWarning('Could not destroy tile, does not exist.')
        return
    end
    _destroyTile(tile, stopNotification)
    _holder.set(index, nil)
    if _overfillCount > 0 then
        local count = _holder.count()
        for i=index + 1, count do
            local movedTile = _holder.get(i)
            _holder.set(i - 1, movedTile)
            if movedTile ~= nil then
                movedTile.index = i - 1
            end
        end
        _holder.remove(count)
        _overfillCount = _overfillCount - 1
        game.control.ui.refreshTiles()
    else
        game.control.ui.updateTile(index)
    end
    game.control.trigger('onInventoryChange')
    _updateInventorySizeIndicator()
end

function tilesHolder.getTile(index)
    return _holder.get(index)
end

function tilesHolder.swapTile(index1, index2)
    local tile1 = _holder.get(index1)
    local tile2 = _holder.get(index2)
    _holder.set(index1, tile2)
    _holder.set(index2, tile1)
    if tile1 ~= nil then
        tile1.index = index2
    end
    if tile2 ~= nil then
        tile2.index = index1
    end
    game.control.ui.updateTile(index1)
    game.control.ui.updateTile(index2)
    game.control.trigger('onInventoryChange')
end

function tilesHolder.canCombine(data1, data2)
    if data1 == nil or data2 == nil then
        return false
    end
    if data1.combination == nil then
        return false
    end
    if data1.combination.target == data2.key then
        return true, data1.combination.product
    end
    return false
end

function tilesHolder.canCombineByIndex(index1, index2)
    local tile1 = _holder.get(index1)
    local tile2 = _holder.get(index2)
    if tile1 == nil or tile2 == nil then
        return
    end
    return tilesHolder.canCombine(tile1.data, tile2.data)
end

function tilesHolder.findImminentCombination(index)
    local x, y = tilesHolder.getCoordinate(index)
    if x < 1 or y < 1 then
        return false
    end
    local left = tilesHolder.getIndex(x - 1, y)
    if left > 0 then
        local canCombine, product = tilesHolder.canCombineByIndex(index, left)
        if canCombine then
            return true, left, product
        end
    end
    local above = tilesHolder.getIndex(x, y - 1)
    if above > 0 then
        local canCombine, product = tilesHolder.canCombineByIndex(index, above)
        if canCombine then
            return true, above, product
        end
    end
    return false
end

-- MOD (save/continue): returns true when a combination animation is pending.
-- onDone (optional) runs once the combinations are finished.
function tilesHolder.combinePending(onDone)
    local count = _holder.count()
    local combined = {}
    local combinationPending = false
    for i=count, 1, -1 do
        if combined[i] == nil then
            local hasCombination, combinedIndex, product = tilesHolder.findImminentCombination(i)
            if hasCombination then
                combined[combinedIndex] = {
                    index1 = combinedIndex,
                    index2 = i,
                    product = product,
                }
                combinationPending = true
            end
        end
    end
    if not combinationPending then
        return false
    end
    local function completeCombinations()
        local data = require('data/scripts/data.lua')
        for _, combination in pairs(combined) do
            local product = data.tiles[combination.product]
            if product ~= nil then
                tilesHolder.destroyTile(combination.index2)
                tilesHolder.setTile(combination.index1, product)
                game.control.trigger('onItemCombine', combination.index1, combination.index2)
            end
        end
        if onDone ~= nil then
            onDone()
        end
    end
    game.control.ui.combineTiles(combined, completeCombinations)
    return true
end

-- MOD (save/continue): shape of the inventory and which tile is in which slot.
function tilesHolder.getSnapshot()
    local slots = {}
    local count = _holder.count()
    for i=1, count do
        local tile = _holder.get(i)
        if tile ~= nil and tile.data ~= nil then
            table.insert(slots, { index = i, key = tile.data.key })
        end
    end
    return {
        height = _height,
        virtualHeight = _virtualHeight,
        overfill = _overfillCount,
        count = count,
        slots = slots,
    }
end

-- MOD (save/continue): rebuilds the inventory from a snapshot. Tiles go through the normal
-- placement path (so their init side effects, like luck, are re-created); row changes made by
-- those inits are ignored because the saved shape is applied first.
function tilesHolder.restoreSnapshot(snapshot)
    local data = require('data/scripts/data.lua')
    _restoring = true
    _height = snapshot.height or _height
    _virtualHeight = snapshot.virtualHeight or _virtualHeight
    _overfillCount = snapshot.overfill or 0
    while _holder.count() < (snapshot.count or 0) do
        _holder.add(nil)
    end
    game.control.ui.refreshTiles()
    for _, slot in ipairs(snapshot.slots or {}) do
        local tileData = data.tiles[slot.key]
        if tileData ~= nil and slot.index <= _holder.count() then
            _setTileToIndex(slot.index, tileData)
        else
            game.debug.logWarning('Save: tile ' .. tostring(slot.key) .. ' could not be restored.')
        end
    end
    _restoring = false
    _updateInventorySizeIndicator()
end

function tilesHolder.isFull()
    if _overfillCount > 0 then
        return true
    end
    local count = _holder.count()
    for i=1, count do
        local tile = _holder.get(i)
        if tile == nil then
            return false
        end
    end
    return true
end

for _=1, _width do
    for _=1, _height do
        _holder.add(nil)
    end
end

return tilesHolder
