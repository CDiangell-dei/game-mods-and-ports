local input = {}

local _down = {}
local _mouseDown = {}
local _mousePosition = {
	x = 0,
	y = 0
}

function input.isMouseDown(button)
	if button == nil then
		return false
	end
	return _mouseDown[button] ~= nil
end

function input.isDown(scancode)
	if scancode == nil then
		return false
	end
	return _down[scancode] ~= nil
end

function input.startInput()
	engine.events.invoke('startInput')
	love.keyboard.setTextInput(true)
end

function input.stopInput()
	engine.events.invoke('stopInput')
	love.keyboard.setTextInput(false)
end

function input.getMousePosition()
	return _mousePosition.x, _mousePosition.y
end

function input.setMousePosition(x, y)
	if type(x) ~= 'number' or type(y) ~= 'number' then
		return
	end
	_mousePosition.x = x
	_mousePosition.y = y
	x, y = engine.graphics.canvasToScreen(x, y)
	love.mouse.setPosition(x, y)
end

function input.update()
	local x, y = love.mouse.getPosition()
	x, y = engine.graphics.screenToCanvas(x, y)
	_mousePosition.x = x
	_mousePosition.y = y
end

function love.wheelmoved(_, y)
	engine.events.invoke('scroll', y)
end

function love.keypressed(_, scancode, _)
	_down[scancode] = 1
	engine.events.invoke('keyPressed', scancode)
end

function love.keyreleased(_, scancode)
	_down[scancode] = nil
	engine.events.invoke('keyReleased', scancode)
end

function love.mousepressed(_, _, button, _, _)
	_mouseDown[button] = 1
	engine.events.invoke('mousePressed', button)
end

function love.mousereleased(_, _, button, _, _)
	_mouseDown[button] = nil
	engine.events.invoke('mouseReleased', button)
end

function love.textinput(text)
	engine.events.invoke('textInput', text)
end

function love.textedited(text, start, length)
	engine.events.invoke('textEdited', text, start, length)
end

love.keyboard.setTextInput(false)

return input