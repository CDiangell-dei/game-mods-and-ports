local system = {}

system.isFocused = love.window.hasFocus
system.openUri = love.system.openURL
system.quit = love.event.quit

function system.cleanGarbage()
	engine.fileSystem.clear()
	collectgarbage()
end

return system