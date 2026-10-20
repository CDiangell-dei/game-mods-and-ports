local debug = {}

local _logLevel = 0
local _console = nil

local function _getLineColor(level)
    if level == 2 then
        return 1.0, 0.35, 0.35, 1.0
    elseif level == 1 then
        return 1.0, 1.0, 0.35, 1.0
    else
        return 1.0, 1.0, 1.0, 1.0
    end
end

local function _spawnLine(level, message)
    if _console ~= nil then
        if _console.isDestroyed() then
            _console = nil
            return
        end
        local count = _console.getChildCount()
        if count > 25 then
            local child = _console.getChild(2)
            child.destroy()
        end
    end
    local line = engine.objectManager.new(_console)
    --line.setPivot(0, 1.0)
    line.setSize(config.canvasWidth, config.defaultFontSize + 2)
    local text = line.addComponent('text')
    text.setOverlay(true)
    text.setVerticalAlignment('top')
    text.setHorizontalAlignment('left')
    text.setTextWrap(true)
    text.setRichText(false)
    text.setControlObjectSize(true)
    local r, g, b, a = _getLineColor(level)
    text.setColor(r, g, b, a)
    local timestamp = '[' .. os.date('%X') .. ']  '
    text.setText(timestamp .. message)
end

local function _spawnConsole()
    _console = engine.objectManager.new()
    _console.setSize(config.canvasWidth, 150)
    _console.setPivot(0, 1.0)
    _console.setPosition(0, 150)
    local background = _console.addComponent('image')
    background.setOverlay(true)
    background.setColor(0, 0, 0, 0.8)
    local group = _console.addComponent('verticalLayoutGroup')
    group.setControlObjectSize(true)
    local spacer = engine.objectManager.new(_console)
    spacer.setPivot(0, 1.0)
    spacer.setSize(config.canvasWidth, 150)
end

local function _log(level, message)
    if type(message) ~= 'string' then
         return
    end
    if _logLevel > level then
        return
    end
    print(message)
    if _console ~= nil then
        _spawnLine(level, message)
    end
end

local function _logObjectTree(parent, start)
    debug.log(start .. parent.name)
    local count = parent.getChildCount()
    for i=1, count do
        local c = parent.getChild(i)
        _logObjectTree(c, start .. parent.name .. '/')
    end
end

function debug.print(message)
    _log(999, message)
end

function debug.log(message)
    _log(0, message)
end

function debug.logWarning(message)
    _log(1, message)
end

function debug.logError(message)
    _log(2, message)
end

function debug.logObjectTree(parent)
    if not engine.typeValidator.isGameType('Object', parent) then
        debug.logError('Supplied object for logObjectTree is invalid type.')
        return
    end
    debug.log('----Object Tree: ' .. parent.name .. '----')
    _logObjectTree(parent, '')
    debug.log('----Complete----')
end

function debug.setLogLevel(logLevel)
    if type(logLevel) ~= 'string' then
        return
    end
    if logLevel == 'verbose' then
        _logLevel = 0
    elseif logLevel == 'warning' then
        _logLevel = 1
    elseif logLevel == 'error' then
        _logLevel = 2
    elseif logLevel == 'none' then
        _logLevel = 1000
    else
        _logLevel = 1
    end
end

function debug.getLogLevel()
    if _logLevel == 0 then
        return 'verbose'
    elseif _logLevel == 1 then
        return 'warning'
    elseif _logLevel == 2 then
        return 'error'
    elseif _logLevel == 1000 then
        return 'none'
    end
end

function debug.toggleConsole()
    if _console == nil then
        _spawnConsole()
    else
        _console.destroy()
        _console = nil
    end
end

function debug.reset()
    if _console ~= nil then
        _console.destroy()
        _console = nil
    end
    _logLevel = 0
end

return debug
