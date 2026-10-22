local graphics = {}

love.graphics.setDefaultFilter('linear', 'nearest')

local _mainCanvas = love.graphics.newCanvas(config.canvasWidth, config.canvasHeight)
local _overlayCanvas = love.graphics.newCanvas(config.canvasWidth, config.canvasHeight)
local _screenWidth = config.canvasWidth
local _screenHeight = config.canvasHeight
local _display = engine.settings.getSetting('display')
local _resolution = engine.settings.getSetting('resolution')
local _vsync = engine.settings.getSetting('vSync')
local _fullscreen = engine.settings.getSetting('fullscreen') > 0.5 or _resolution == 0
local _isWindowed = _resolution ~= 0
local _isResizing = false
local _passes = {
	{
		shader = nil,
		canvas = love.graphics.newCanvas(_screenWidth, _screenHeight),
	},
}
local _fontDefaults = {
	[config.defaultFontSize] = config.defaultFont,
}
local _colors = {}

local function _calculateScaling()
	local canvasRatio = config.canvasWidth / config.canvasHeight
	local width = _screenWidth
	local height = _screenHeight
	local windowRatio = width / height
	local offsetX = 0
	local offsetY = 0
	local scale = 1.0
	if windowRatio > canvasRatio then
		local ratioWidth = canvasRatio * height
		local offset = (width - ratioWidth) * 0.5
		scale = height / config.canvasHeight
		offsetX = math.floor(offset)
	else
		local ratioHeight = width / canvasRatio
		local offset = (height - ratioHeight) * 0.5
		scale = width / config.canvasWidth
		offsetY = math.floor(offset)
	end
	return offsetX, offsetY, scale
end

local function _refreshCanvases()
	for _, pass in ipairs(_passes) do
		if pass.canvas ~= nil then
			pass.canvas = love.graphics.newCanvas(_screenWidth, _screenHeight)
		end
	end
	local canvasRatio = config.canvasWidth / config.canvasHeight
	local windowRatio = _screenWidth / _screenHeight
	local width
	local height
	if windowRatio > canvasRatio then
		width = (windowRatio / canvasRatio) * config.canvasWidth
		height = config.canvasHeight
	else
		width = config.canvasWidth
		height = (canvasRatio / windowRatio) * config.canvasHeight
	end
	_mainCanvas = love.graphics.newCanvas(width, height)
	_overlayCanvas = love.graphics.newCanvas(width, height)
end

local function _preventWindowBarHidden()
	if not _isWindowed then
		return
	end
	local x, y, displayIndex = love.window.getPosition()
	local titleBarSize = 40 --default windows size
	if y < titleBarSize then
		love.window.setPosition(x, titleBarSize, displayIndex)
	end
end

local function _refreshBase()
	if not _fullscreen and _resolution == 0 then
		_resolution = 1
	end
	if _fullscreen or _resolution == 0 or love.system.getOS() == 'Android' then
		_isWindowed = false
		local dw, dh = love.window.getDesktopDimensions(_display)
		_screenWidth = dw or 675
		_screenHeight = dh or 540
	else
		_isWindowed = true
		_screenWidth = _resolution * config.canvasWidth
		_screenHeight = _resolution * config.canvasHeight
	end
	_refreshCanvases()

	local flags = {
		display = _display,
		vsync = _vsync,
		resizable = true,
		minwidth = config.canvasWidth,
		minheight = config.canvasHeight,
	}
	if _fullscreen and love.system.getOS() ~= 'Web' then
		flags.fullscreen = true
		flags.fullscreentype = 'desktop'
	end
	love.window.setMode(_screenWidth, _screenHeight, flags)
end

local _androidSizeLocked = false

local function _resize(width, height)
	if type(width) ~= 'number' or type(height) ~= 'number' or width <= 0 or height <= 0 then
		return
	end
	if _isResizing then
		return
	end
	-- MOD (rotation fix): on Android the activity is locked to a fixed
	-- landscape orientation and is not resizable (see AndroidManifest.xml),
	-- so its real rendering surface size is only ever set once, at launch.
	-- When the phone is physically rotated, Android still briefly reports a
	-- size change as part of the rotation transition even though the locked
	-- activity doesn't actually rotate or resize. Applying that transient
	-- size here left the canvases mismatched with the real screen
	-- afterwards, which showed up as a black area covering part of the
	-- game. Since this build's surface size never legitimately changes
	-- after the first frame, lock it after the first valid landscape size.
	if love.system.getOS() == 'Android' then
		if _androidSizeLocked then
			return
		end
		if height > width then
			return
		end
		_androidSizeLocked = true
	end
	_isResizing = true
	_screenWidth = width
	_screenHeight = height
	_refreshCanvases()
	_isResizing = false
end

local function _refresh(previousResolution)
	if love.system.getOS() == 'Web' then
		--_refreshBase()
		_isWindowed = true
		_screenWidth = 1 * config.canvasWidth
		_screenHeight = 1 * config.canvasHeight
		--_refreshCanvases()
		local flags = {
			display = 1,
			vsync = 1,
		}
		--_refreshCanvases()
		--love.window.setMode(_screenWidth, _screenHeight, flags)
	else
		_refreshBase()
		_preventWindowBarHidden()
	end
end

local function _renderWorld()
	love.graphics.setCanvas({_mainCanvas, stencil=true})
	love.graphics.clear(0, 0, 0)
	engine.objectManager.draw()

	love.graphics.setCanvas(_passes[1].canvas)
	love.graphics.clear(0, 0, 0)
	local _, _, scale = _calculateScaling()
	love.graphics.draw(_mainCanvas, 0, 0, 0, scale, scale)
end

local function _renderOverlay()
	love.graphics.setCanvas({_overlayCanvas, stencil=true})
	love.graphics.setShader(nil)
	love.graphics.clear(0, 0, 0, 0)
	engine.objectManager.overlay()

	love.graphics.setCanvas(nil)
	local _, _, scale = _calculateScaling()
	love.graphics.draw(_overlayCanvas, 0, 0, 0, scale, scale)
end

local function _renderToScreen(pass)
	love.graphics.setCanvas(nil)
	love.graphics.setShader(pass.shader)
	love.graphics.draw(pass.canvas)
end

function graphics.screenToCanvas(x, y)
	if type(x) ~= 'number' or type(y) ~= 'number' then
		return 0, 0
	end
	local offsetX, offsetY, scale = _calculateScaling()
	x = (x - offsetX) / scale
	y = (y - offsetY) / scale
	return x, y
end

function graphics.canvasToScreen(x, y)
	if type(x) ~= 'number' or type(y) ~= 'number' then
		return 0, 0
	end
	local offsetX, offsetY, scale = _calculateScaling()
	x = (x * scale) + offsetX
	y = (y * scale) + offsetY
	return x, y
end

function graphics.getScaledOffset()
	local offsetX, offsetY, scale = _calculateScaling()
	offsetX = offsetX / scale
	offsetX = math.floor(offsetX + 0.5)
	offsetY = offsetY / scale
	offsetY = math.floor(offsetY + 0.5)
	return offsetX, offsetY
end

function graphics.getRenderScale()
	local _, _, scale = _calculateScaling()
	return scale
end

function graphics.getDimensions()
	return _screenWidth, _screenHeight
end

function graphics.addPostProcess(shader)
	if not engine.typeValidator.isShader(shader) then
		return
	end
	if _passes[1].shader == nil then
		_passes[1].shader = shader
		return
	end
	local renderCanvas = love.graphics.newCanvas(_screenWidth, _screenHeight)
	table.insert(_passes, {
		shader = shader,
		canvas = renderCanvas,
	})
end

function graphics.removePostProcess(shader)
	if not engine.typeValidator.isShader(shader) then
		return
	end
	local count = #_passes
	if count == 1 then
		if _passes[1].shader == shader then
			_passes[1].shader = nil
		end
		return
	end
	local rearrange = false
	for i=1, count do
		if rearrange then
			_passes[i - 1].shader = _passes[i].shader
		end
		if shader == _passes[i].shader then
			_passes[i].shader = nil
			rearrange = true
		end
	end
	if rearrange then
		_passes[count] = nil
	end
end

function graphics.clearPostProcessors()
	_passes[1].shader = nil
	local count = #_passes
	for i=2, count do
		_passes[i] = nil
	end
end

function graphics.hexToColor(code)
	if type(code) ~= 'string' then
		return 0, 0, 0, 0
	end
	local r, g, b, a
    if #code ~= 6 and #code ~= 8 then
        return 0, 0, 0, 0
    end
    if #code >= 6 then
        r = tonumber(string.sub(code, 1, 2), 16)
        g = tonumber(string.sub(code, 3, 4), 16)
        b = tonumber(string.sub(code, 5, 6), 16)
    end

    if #code == 8 then
        a = tonumber(string.sub(code, 7, 8), 16)
    else
        a = 255
    end
    return r / 255.0, g / 255.0, b / 255.0, a / 255.0
end

function graphics.addDefaultFont(size, font)
	_fontDefaults[size] = font
end

function graphics.getDefaultFont(size)
	local selectedFont = nil
	local selectedSize = 0
	for fontSize, font in pairs(_fontDefaults) do
		if fontSize > selectedSize and size >= fontSize then
			selectedFont = font
			selectedSize = fontSize
		end
	end
	if selectedFont == nil then
		return engine.fileSystem.loadFont(config.defaultFont, config.defaultFontSize)
	else
		return engine.fileSystem.loadFont(selectedFont, size)
	end
end

function graphics.addColorKey(key, code)
	if type(key) ~= 'string' then
		engine.debug.logError('Invalid color key. Not type of string.')
		return
	end
	if type(code) ~= 'string' then
		engine.debug.logError('Invalid color code. Not type of string.')
		return
	end
	_colors[key] = code
end

function graphics.getColor(key)
	if type(key) ~= 'string' then
		return nil
	end
	return _colors[key]
end

function graphics.update()
	local vsync = engine.settings.getSetting('vSync')
	if vsync ~= _vsync then
		_vsync = vsync
		love.window.setVSync(vsync)
	end
	local display = engine.settings.getSetting('display')
	if _isWindowed then
		local _, _, displayIndex = love.window.getPosition()
		if display ~= displayIndex then
			engine.settings.setSetting('display', displayIndex)
			display = displayIndex
		end
	end
	local resolution = engine.settings.getSetting('resolution')
	local fullscreen = engine.settings.getSetting('fullscreen') > 0.5
	if _isWindowed and resolution == _resolution and fullscreen == _fullscreen then
		_display = display
		return
	end
	if display == _display and resolution == _resolution and fullscreen == _fullscreen then
		return
	end
	_display = display
	engine.settings.setSetting('display', _display)
	local previousResolution = _resolution
	_resolution = resolution
	_fullscreen = fullscreen
	_refresh(previousResolution)
end

function love.resize(width, height)
	_resize(width, height)
end

function love.draw()
	_renderWorld()

	--Post Processing
	local passCount = #_passes
	for i=2, passCount do
		local previous = _passes[i - 1]
		local pass = _passes[i]
		love.graphics.setCanvas(pass.canvas)
		love.graphics.setShader(previous.shader)
		love.graphics.clear(0, 0, 0)
		love.graphics.draw(previous.canvas)
	end

	local finalPass = _passes[#_passes]
	_renderToScreen(finalPass)

	_renderOverlay()
end
_refresh()

return graphics
