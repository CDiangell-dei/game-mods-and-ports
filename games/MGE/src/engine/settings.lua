local settings = {}

local _progressPoints = {}
local _state = {}

local function _saveDictionary(dictionary, path)
	local list = {}
	for k, v in pairs(dictionary) do
		local dataPair = {
			id = k,
			value = v,
		}
		table.insert(list, dataPair)
	end
	local jsonData = engine.json.serialize(list)
	love.filesystem.write(path, jsonData)
end

local function _saveTo(parentFolder)
	_saveDictionary(_state, parentFolder .. 'settings.json')
	_saveDictionary(_progressPoints, parentFolder .. 'game.sav')
end

function settings.getSetting(key)
	if key == nil then
		return 0
	end
	return _state[key] or 0
end

function settings.setSetting(key, value)
	if type(key) ~= 'string' or type(value) ~= 'number' then
		return
	end
	_state[key] = value
end

function settings.getProgress(key)
	if type(key) ~= 'string' then
		return 0
	end
	return _progressPoints[key] or 0
end

function settings.setProgress(key, value)
	if type(key) ~= 'string' or type(value) ~= 'number' then
		return
	end
	_progressPoints[key] = value
end

function settings.save()
	_saveTo('')
end

local function _loadJson(path)
	local info = love.filesystem.getInfo(path)
    if info == nil or info.type ~= 'file' then
        return nil
    end
	local contents = love.filesystem.read(path)
	if contents == nil then
		return nil
	end
	return engine.json.deserialize(contents)
end

local function _deleteFolder(folder)
	if love.filesystem.getInfo(folder, 'directory') then
		for _, child in ipairs(love.filesystem.getDirectoryItems(folder)) do
			_deleteFolder(folder .. '/' .. child)
			love.filesystem.remove(folder .. '/' .. child)
		end
	elseif love.filesystem.getInfo(folder) then
		love.filesystem.remove(folder)
	end
	love.filesystem.remove(folder)
end

local function _loadState()
	local state = _loadJson('settings.json')
	if state == nil then
		for k, v in pairs(config.settings) do
			_state[k] = v
		end
	else
		for _, value in ipairs(state) do
			_state[value.id] = value.value
		end
	end

	local save = _loadJson('game.sav')
	if save ~= nil then
		for _, point in ipairs(save) do
			_progressPoints[point.id] = point.value
		end
	end
end

local function _backup()
	for i=1, 5 do
		love.filesystem.createDirectory('backup_' .. tostring(i))
	end
	local saveDirectory = love.filesystem.getSaveDirectory()
	_deleteFolder('backup_5')
	for i=4, 1, -1 do
		local updatedName = saveDirectory .. '/backup_' .. tostring(i + 1)
		local currentName = saveDirectory .. '/backup_' .. tostring(i)
		os.rename(currentName, updatedName)
	end
	love.filesystem.createDirectory('backup_1')
	_saveTo('backup_1/')
end

_loadState()
--_backup()

return settings
