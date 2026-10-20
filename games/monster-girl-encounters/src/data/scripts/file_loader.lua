local fileLoader = {}

local _files = {}
local _index = 0

local function _getFiles(folder)
    local files = love.filesystem.getDirectoryItems(folder)
    for _, file in ipairs(files) do
        local path = folder .. file
        local info = love.filesystem.getInfo(path)
        if info then
            if info.type == 'file' then
                table.insert(_files, path)
            elseif info.type == 'directory' then
                _getFiles(path .. '/')
            end
        end
    end
end

local function _getExtension(file)
    local _, _, extension = string.find(file, '%.([^%.]+)$')
    return extension
end

local function _fileIsInAnimationFolder(file)
    local startIndex, _ = string.find(file, 'data/animations/')
    return startIndex ~= nil
end

local function _loadNextFile()
    local file = _files[_index + 1]
    if file == nil then
        _index = _index + 1
        return
    end
    local fileType = _getExtension(file)
    if fileType == 'json' and _fileIsInAnimationFolder(file) then
        engine.fileSystem.loadAnimation(file)
    elseif fileType == 'json' then
        engine.fileSystem.loadString(file)
    elseif fileType == 'ogg' or fileType == 'wav' then
        engine.fileSystem.loadSound(file)
    elseif fileType == 'png' then
        engine.fileSystem.loadSprite(file)
    elseif fileType == 'csv' then
        engine.fileSystem.loadCsv(file)
    elseif fileType == 'frag' then
        engine.fileSystem.loadShader(file)
    end
    _index = _index + 1
end

function fileLoader.getProgress()
    return _index / #_files
end

function fileLoader.update()
    local start = love.timer.getTime()
    local current = start
    local timePerFrame = 1 / 60.0
    while current - start < timePerFrame and _index < #_files do
        _loadNextFile()
        current = love.timer.getTime()
    end
end

_getFiles('')

return fileLoader
