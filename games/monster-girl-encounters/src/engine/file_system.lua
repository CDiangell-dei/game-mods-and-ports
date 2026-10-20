local fileSystem = {}

local _cache = {}
local _fontCache = {}
local _timer = 0.0
local _cacheTimer = 300

local function _getFile(path)
    local info = love.filesystem.getInfo(path)
    if info == nil or info.type ~= 'file' then
        return nil
    end
    return love.filesystem.newFileData(path)
end

local function _getString(path)
    local file = _getFile(path)
    if file == nil then
        return nil
    end
    return file:getString()
end

local function _addToCache(key, obj)
    _cache[key] = {
        object = obj,
        timer = _cacheTimer,
    }
end

local function _getRefreshedObject(key)
    local obj = _cache[key]
    obj.timer = _cacheTimer
    return obj.object
end

local function _getFontSet(path)
    local fontSet = _fontCache[path]
    if fontSet == nil then
        local file = _getFile(path)
        if file == nil then
            return nil
        end
        fontSet = {
            baseFont = file,
            fonts = {}
        }
        _fontCache[path] = fontSet
    end
    return fontSet
end

function fileSystem.loadString(path)
    if type(path) ~= 'string' then
        return nil
    end
    if _cache[path] ~= nil then
        return _getRefreshedObject(path)
    end
    local data = _getString(path)
    if data == nil then
        return nil
    end
    _addToCache(path, data)
    return data
end

function fileSystem.loadJson(path)
    if type(path) ~= 'string' then
        return nil
    end
    if _cache[path] ~= nil then
        local obj = _getRefreshedObject(path)
        return engine.json.deserialize(obj)
    end
    local data = _getString(path)
    if data == nil then
        return nil
    end
    _addToCache(path, data)
    return engine.json.deserialize(data)
end

function fileSystem.loadCsv(path)
    if type(path) ~= 'string' then
        return nil
    end
    if _cache[path] ~= nil then
        local obj = _getRefreshedObject(path)
        return engine.csv.parse(obj)
    end
    local data = _getString(path)
    if data == nil then
        return nil
    end
    _addToCache(path, data)
    return engine.csv.parse(data)
end

function fileSystem.loadSprite(path)
    if type(path) ~= 'string' then
        return nil
    end
    if _cache[path] ~= nil then
        return _getRefreshedObject(path)
    end
    local file = _getFile(path)
    if file == nil then
        return nil
    end
    local success, image = pcall(love.graphics.newImage, file)
    if not success then
        engine.debug.logError('Failed to load sprite: ' .. path)
        if image ~= nil then
            engine.debug.logError(image)
        end
        return nil
    end
    image:setWrap('repeat', 'repeat')
    _addToCache(path, image)
    return image
end

function fileSystem.loadShader(path)
    if type(path) ~= 'string' then
        return nil
    end
    if _cache[path] ~= nil then
        return _getRefreshedObject(path)
    end
    local data = _getString(path)
    if data == nil then
        return nil
    end
    local success, shader = pcall(love.graphics.newShader, data)
    if not success then
        engine.debug.logError('Failed to load shader: ' .. path)
        if shader ~= nil then
            engine.debug.logError(shader)
        end
        return nil
    end
    _addToCache(path, shader)
    return shader
end

function fileSystem.loadSound(path)
    if type(path) ~= 'string' then
        return nil
    end
    if _cache[path] ~= nil then
        return _getRefreshedObject(path)
    end
    local file = _getFile(path)
    if file == nil then
        return nil
    end
    local sourceType
    if engine.string.endsWith(path, '.ogg') then
        sourceType = 'stream'
    else
        sourceType = 'static'
    end
    local success, source = pcall(love.audio.newSource, file, sourceType)
    if not success then
        engine.debug.logError('Failed to load sound: ' .. path)
        if source ~= nil then
            engine.debug.logError(source)
        end
        return nil
    end
    _addToCache(path, source)
    return source
end

function fileSystem.loadFont(path, size)
    if type(path) ~= 'string' then
        return nil
    end
    local fontSet = _getFontSet(path)
    if fontSet == nil then
        return nil
    end
    local fontTimer = fontSet.fonts[size]
    if fontTimer ~= nil then
        fontTimer.timer = _cacheTimer
        return fontTimer.font
    end

    local success, font = pcall(love.graphics.newFont, fontSet.baseFont, size)
    if not success then
        engine.debug.logError('Failed to load font: ' .. path)
        if font ~= nil then
            engine.debug.logError(font)
        end
        return nil
    end
    --font:setFilter("nearest")
    fontTimer = {
        timer = _cacheTimer,
        font = font,
    }
    fontSet.fonts[size] = fontTimer
    return font
end

function fileSystem.loadAnimation(path)
    if type(path) ~= 'string' then
        return nil
    end
    if _cache[path] ~= nil then
        return _getRefreshedObject(path)
    end
    local data = _getString(path)
    if data == nil then
        return nil
    end
    local animation = engine.json.deserialize(data)
    if animation == nil then
        return nil
    end
    animation.activeFrames = {}
    animation.events = {}
    local index = 1
    local currentSprite = nil
    if type(animation.frames) ~= 'table' then
        return nil
    end
    for _, frame in ipairs(animation.frames) do
        local sprite = fileSystem.loadSprite(frame.sprite)
        while index < frame.frame do
            table.insert(animation.activeFrames, currentSprite)
            index = index + 1
        end
        if sprite ~= nil then
            table.insert(animation.activeFrames, sprite)
            index = index + 1
            currentSprite = sprite
        end
        animation.events[frame.frame] = frame.events
    end
    _addToCache(path, animation)
    return animation
end

function fileSystem.fileExists(path)
    local info = love.filesystem.getInfo(path)
    if info == nil then
        return false
    end
    return info.type == 'file'
end

function fileSystem.clear()
    _cache = {}
    _fontCache = {}
end

function fileSystem.update(dt)
    _timer = _timer + dt
    local timePerTick = 10.0
    if _timer < timePerTick then
        return
    end
    _timer = 0
    for k, v in pairs(_cache) do
        v.timer = v.timer - timePerTick
        if v.timer <= 0 then
            _cache[k] = nil
        end
    end

    for path, fontSet in pairs(_fontCache) do
        local isEmpty = true
        for size, fontTimer in pairs(fontSet.fonts) do
            fontTimer.timer = fontTimer.timer - timePerTick
            if fontTimer.timer <= 0 then
                fontSet.fonts[size] = nil
            else
                isEmpty = false
            end
        end
        if isEmpty then
            _fontCache[path] = nil
        end
    end
end

return fileSystem
