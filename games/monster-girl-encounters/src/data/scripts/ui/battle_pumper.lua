local pumper = {}

local _time = 0
local _pumpData = nil
local _multiplier = 1.0
local _iterateCount = 0
local _currentIndex = 0
local _clearTimer = 0
local _timeSinceLastPump = 0
local _speedMultiplier = 1.0

local function _playSound(iterations)
    local pitch = 1.0 + (iterations * 0.05)
    game.audio.playSound('data/sounds/general/tile_iteration.json', pitch)
end

local function _clearHighlight()
    local count = game.control.tiles.getCount()
    for i=1, count do
        game.control.ui.unhighlightTile(i)
    end
    game.control.ui.refreshPossibleCombinations()
end

local function _setHighlight(tile)
    game.control.ui.highlightTile(tile.index)
    game.control.ui.spawnTileOrb(tile.index)
end

local function _findNextTileIndex(data)
    local max = #data
    for i=_currentIndex + 1, max do
        local d = data[i]
        if d.data.type == 'tile' then
            _currentIndex = i
            return
        end
    end
    _currentIndex = -1
end

local function _iterateImmediate(data)
    game.audio.playSound('data/sounds/general/tile_super.json')
    _clearHighlight()
    local count = #data
    for i=_currentIndex, count do
        local tile = data[i]
        _setHighlight(tile)
    end
    _clearTimer = 0.2
    _pumpData = nil
end

local function _iterateWhileWithinTime(data)
    _iterateCount = _iterateCount + 1
    if _iterateCount > 10 then
        _iterateImmediate(data)
        return
    end
    local current = (1.0 - math.exp(-_iterateCount * _multiplier)) * _speedMultiplier
    local previous = (1.0 - math.exp(-(_iterateCount - 1) * _multiplier)) * _speedMultiplier
    local increment = current - previous
    _clearTimer = increment
    _time = _time + increment
    _playSound(_iterateCount)
    local tile = data[_currentIndex]
    _clearHighlight()
    _setHighlight(tile)
    _findNextTileIndex(data)
    if _currentIndex == -1 then
        _pumpData = nil
    end
end

local function _getTileCount(pumpers)
    local count = 0
    for _, data in ipairs(pumpers) do
        if data.data.type == 'tile' then
            count = count + 1
        end
    end
    return count
end

function pumper.refresh()
    _pumpData = nil
    _timeSinceLastPump = 0
    _clearTimer = 0
    _clearHighlight()
end

function pumper.update(deltaTime)
    _timeSinceLastPump =_timeSinceLastPump + deltaTime
    if _pumpData == nil then
        if _clearTimer > 0 then
            _clearTimer = _clearTimer - deltaTime
            if _clearTimer <= 0 then
                _clearHighlight()
            end
        end
        return
    end
    _time = _time - deltaTime
    while _time <= 0 and _pumpData ~= nil do
        _iterateWhileWithinTime(_pumpData)
    end
end

function pumper.pump(pumpers)
    _currentIndex = 0
    _findNextTileIndex(pumpers)
    if _currentIndex == -1 then
        return
    end
    local tileCount = _getTileCount(pumpers)
    tileCount = math.max(10, tileCount)
    _pumpData = pumpers
    _multiplier = 1.5 / tileCount
    _time = 0
    _iterateCount = 0
    local timePassed = _timeSinceLastPump
    timePassed = math.min(1.0, timePassed)
    _speedMultiplier = timePassed
    _timeSinceLastPump = 0
end

return pumper
