engine = {}

local _scripts = {}
local _compiled = {}

local _hasInit = false

function engine.require(path)
    local script = _scripts[path]
    if script == nil then
        script = love.filesystem.load(path)()
        _scripts[path] = script
    end
    return script
end

function engine.dofile(path)
    local loader = _compiled[path]
    if loader == nil then
        loader = love.filesystem.load(path)
        _compiled[path] = loader
    end
    return loader()
end

--Table updates
table.pack = function(...)
    return {...}
end
table.unpack = unpack

engine.string = engine.require('engine/string_manipulation.lua')
engine.typeValidator = engine.require('engine/type_validator.lua')
engine.csv = engine.require('engine/csv.lua')
engine.json = engine.require('engine/json.lua')
engine.debug = engine.require('engine/debug.lua')
engine.events = engine.require('engine/event_handler.lua')
engine.fileSystem = engine.require('engine/file_system.lua')
engine.settings = engine.require('engine/settings.lua')
engine.timer = engine.require('engine/timer.lua')
engine.system = engine.require('engine/system.lua')
engine.audio = engine.require('engine/audio_manager.lua')
engine.music = engine.require('engine/music_player.lua')
engine.input = engine.require('engine/input.lua')
engine.objectManager = engine.require('engine/object_manager.lua')
engine.graphics = engine.require('engine/graphics.lua')
engine.translator = engine.require('engine/translator.lua')
engine.sandbox = love.filesystem.load('engine/sandbox.lua')()

function engine.resetSandbox()
    engine.sandbox = love.filesystem.load('engine/sandbox.lua')()
end

function love.update(dt)
    if not _hasInit then
        engine.events.invoke('init')
        _hasInit = true
    end
    engine.input.update()
    engine.timer.update(dt)
    engine.events.invoke('update')
    engine.objectManager.update()
    engine.graphics.update()
    engine.audio.update()
    engine.music.update()
    engine.objectManager.lateUpdate()
    --engine.fileSystem.update(dt)
end

function love.quit()
    engine.events.invoke('quit')
    engine.settings.save()
end
