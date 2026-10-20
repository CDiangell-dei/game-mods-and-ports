local width = game.control.tiles.getWidth()
local height = game.control.tiles.getHeight()
local data = require('data/scripts/data.lua')
local doll = data.tiles['doll']
local lifegem = data.tiles['lifegem']

local function process(x, y)
    local index = game.control.tiles.getIndex(x, y)
    local tile = game.control.tiles.getTile(index)
    if tile == nil then
        return
    end
    if tile.data == doll then
        game.control.tiles.setTile(index, data.tiles['doll_off'])
    end
    if tile.data == lifegem then
        game.control.tiles.setTile(index, data.tiles['lifegem_off'])
    end
end

for x = 1, width do
    for y = 1, height do
        process(x, y)
    end
end

game.control.shield = 0
while game.control.lives > 1 do
    game.control.loseLife()
end

local function fadeIn()
    game.control.ui.fadeIn(nil)
end

local function delayFadeIn()
    game.timer.queue(2.0, fadeIn)
end

game.control.ui.fadeToBlack(delayFadeIn, 0.001)
game.audio.playSound('data/sounds/general/start_battle.json')
