local logFile = io.open("C:/Jogos/MGE/debug_run.log", "w")

local function debugLog(msg)
    if logFile then
        logFile:write(os.date("[%H:%M:%S] ") .. tostring(msg) .. "\n")
        logFile:flush()
    end
end

debugLog("main.lua loaded")

local orig_errhand = love.errorhandler
function love.errorhandler(msg)
    debugLog("ERROR HANDLER TRIGGERED: " .. tostring(msg))
    debugLog(debug.traceback())
    if orig_errhand then
        return orig_errhand(msg)
    end
end

function love.load()
    debugLog("love.load() started")
    
    debugLog("Loading engine/engine.lua...")
    local ok1, err1 = pcall(function()
        love.filesystem.load('engine/engine.lua')()
    end)
    if not ok1 then
        debugLog("FAILED engine/engine.lua: " .. tostring(err1))
        error(err1)
    end
    debugLog("engine/engine.lua loaded successfully")

    debugLog("Loading data/scripts/init.lua...")
    local ok2, err2 = pcall(function()
        love.filesystem.load('data/scripts/init.lua')()
    end)
    if not ok2 then
        debugLog("FAILED data/scripts/init.lua: " .. tostring(err2))
        error(err2)
    end
    debugLog("data/scripts/init.lua loaded successfully")
    debugLog("love.load() finished successfully")
end

local orig_quit = love.quit
function love.quit()
    debugLog("love.quit() called!")
    if orig_quit then return orig_quit() end
    return false
end
