local sandbox = {
	_VERSION = _VERSION,
	assert = assert,
    debug = debug, --REMOVE THIS?
    error = error,
    getmetatable = getmetatable,
    ipairs = ipairs,
    next = next,
    pairs = pairs,
    pcall = pcall,
    print = engine.debug.print,
    select = select,
    setmetatable = setmetatable,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    xpcall = xpcall,
    coroutine = {
        create = coroutine.create,
        resume = coroutine.resume,
        running = coroutine.running,
        status = coroutine.status,
        wrap = coroutine.wrap,
        yield = coroutine.yield,
    },
    string = {
        byte = string.byte,
        char = string.char,
        find = string.find,
        format = string.format,
        gmatch = string.gmatch,
        gsub = string.gsub,
        len = string.len,
        lower = string.lower,
        match = string.match,
        rep = string.rep,
        reverse = string.reverse,
        sub = string.sub,
        upper = string.upper,
    },
    table = {
        concat = table.concat,
        insert = table.insert,
        move = table.move,
        pack = table.pack,
        remove = table.remove,
        sort = table.sort,
        unpack = table.unpack,
    },
    math = {
        abs = math.abs,
        acos = math.acos,
        asin = math.asin,
        atan = math.atan,
        ceil = math.ceil,
        cos = math.cos,
        deg = math.deg,
        exp = math.exp,
        floor = math.floor,
        fmod = math.fmod,
        huge = math.huge,
        log = math.log,
        max = math.max,
        min = math.min,
        modf = math.modf,
        pi = math.pi,
        rad = math.rad,
        random = math.random,
        randomseed = math.randomseed,
        sin = math.sin,
        sqrt = math.sqrt,
        tan = math.tan,
    },
    os = {
        clock = os.clock,
        date = os.date,
        difftime = os.difftime,
        time = os.time,
    },
    _MODULES = {
        compiled = {},
        loaded = {},
		returns = {},
    },
    love = love,
    game = {
        audio = {
            playSound = engine.audio.play,
            stopAllSounds = engine.audio.stop,
            playMusic = engine.music.play,
            stopMusic = engine.music.stop,
            pauseMusic = engine.music.pause,
            resumeMusic = engine.music.resume,
            adjustMusicPitch = engine.music.adjustPitch,
        },
        config = {
            isDevelopment = config.isDevelopment,
            canvasWidth = config.canvasWidth,
            canvasHeight = config.canvasHeight,
        },
        json = {
            serialize = engine.json.serialize,
            deserialize = engine.json.deserialize,
        },
        timer = {
            getTimescale = engine.timer.getTimescale,
            setTimescale = engine.timer.setTimescale,
            getDeltaTime = engine.timer.getDeltaTime,
            getUnscaledDeltaTime = engine.timer.getUnscaledDeltaTime,
            getTime = engine.timer.getTime,
            getUnscaledTime = engine.timer.getUnscaledTime,
            startCoroutine = engine.timer.startCoroutine,
            stopCoroutine = engine.timer.stopCoroutine,
            queue = engine.timer.queue,
            queueScaled = engine.timer.queueScaled,
        },
        display = {
            screenToCanvas = engine.graphics.screenToCanvas,
            canvasToScreen = engine.graphics.canvasToScreen,
            getRenderScale = engine.graphics.getRenderScale,
            getDimensions = engine.graphics.getDimensions,
            addPostProcess = engine.graphics.addPostProcess,
            removePostProcess = engine.graphics.removePostProcess,
            hexToColor = engine.graphics.hexToColor,
            addColorKey = engine.graphics.addColorKey,
            getColor = engine.graphics.getColor,
        },
        input = {
            isMouseDown = engine.input.isMouseDown,
            isDown = engine.input.isDown,
            getMousePosition = engine.input.getMousePosition,
            setMousePosition = engine.input.setMousePosition,
        },
        data = {
            loadString = engine.fileSystem.loadString,
            loadJson = engine.fileSystem.loadJson,
            loadCsv = engine.fileSystem.loadCsv,
            loadSprite = engine.fileSystem.loadSprite,
            loadShader = engine.fileSystem.loadShader,
            loadSound = engine.fileSystem.loadSound,
            loadFont = engine.fileSystem.loadFont,
            loadAnimation = engine.fileSystem.loadAnimation,
            getSetting = engine.settings.getSetting,
            setSetting = engine.settings.setSetting,
            getProgress = engine.settings.getProgress,
            setProgress = engine.settings.setProgress,
            save = engine.settings.save,
        },
        debug = {
            log = engine.debug.log,
            logWarning = engine.debug.logWarning,
            logError = engine.debug.logError,
            setLogLevel = engine.debug.setLogLevel,
            getLogLevel = engine.debug.getLogLevel,
            toggleConsole = engine.debug.toggleConsole,
            logObjectTree = engine.debug.logObjectTree,
        },
        events = {
            subscribe = engine.events.subscribe,
            unsubscribe = engine.events.unsubscribe,
            invoke = engine.events.invoke,
        },
        object = {
            new = engine.objectManager.new,
            instantiate = engine.objectManager.instantiate,
            getRoot = engine.objectManager.getRoot,
            setVisual = engine.objectManager.setVisual,
        },
        text = {
            getText = engine.translator.getText,
            getLanguage = engine.translator.getLanguage,
            setLanguage = engine.translator.setLanguage,
            addTranslation = engine.translator.addTranslation,
        },
        string = {
            splitWithDelimiters = engine.string.splitWithDelimiters,
            split = engine.string.split,
            codes = engine.string.codes,
            char = engine.string.char,
            startsWith = engine.string.startsWith,
            endsWith = engine.string.endsWith,
            sub = engine.string.sub,
            len = engine.string.len,
        }
    },
}

local function _findOrCompileScriptIntoSandbox(key)
    if sandbox._MODULES.compiled[key] ~= nil then
        return sandbox._MODULES.compiled[key]
    end
    local code = engine.fileSystem.loadString(key)
    if code == nil then
        engine.debug.logError('Script at ' .. key .. ' does not exist.')
        return nil
    end
    local compiledScript, error = loadstring(code)
    --[[
    local sent = false
    local function sendCode()
        if sent then
            return nil
        end
        sent = true
        return code
    end
    local compiledScript, error = load(sendCode, nil, 't', sandbox)
    ]]--
    if compiledScript == nil then
        engine.debug.logError('Failed to compile script at: ' .. key .. ' ; ' .. error)
        return nil
    end
    setfenv(compiledScript, sandbox)
    sandbox._MODULES.compiled[key] = compiledScript
    return compiledScript
end

function sandbox.dofile(key)
	if key == nil or key == '' then
        engine.debug.logError('Could not dofile script, key is nil or empty.')
        return nil
    end
    local compiledScript = _findOrCompileScriptIntoSandbox(key)
    if compiledScript == nil then
        return nil
    end
	local returnValues = table.pack(pcall(compiledScript))
	if returnValues[1] ~= true then
		engine.debug.logError('Failed to run script due to error at: ' .. key)
        local err = returnValues[2]
        if err ~= nil then
            engine.debug.logError(returnValues[2])
        end
		return nil
	end
	table.remove(returnValues, 1)
    return table.unpack(returnValues)
end

function sandbox.dostring(code)
	if code == nil or code == '' then
        engine.debug.logError('Could not compile string, code is nil or empty.')
        return nil
    end
    local compiledScript, error = loadstring(code)
    --[[
    local sent = false
    local function sendCode()
        if sent then
            return nil
        end
        sent = true
        return code
    end
    local compiledScript, error = load(sendCode, nil, 't', sandbox)
    ]]--
    if compiledScript == nil then
        engine.debug.logError('Failed to compile script from string: ' .. error)
        return nil
    end
    setfenv(compiledScript, sandbox)
	local returnValues = table.pack(pcall(compiledScript))
	if returnValues[1] ~= true then
		engine.debug.logError('Failed to run script from string due to error.')
		return nil
	end
	table.remove(returnValues, 1)
    return table.unpack(returnValues)
end

function sandbox.require(key)
	if key == nil or key == '' then
        engine.debug.logError('Could not require script, key is nil or empty.')
        return nil
    end
    if sandbox._MODULES.loaded[key] == 1 then
        return sandbox._MODULES.returns[key]
    end
    local result = sandbox.dofile(key)
    sandbox._MODULES.loaded[key] = 1
	sandbox._MODULES.returns[key] = result
    return result
end

return sandbox
