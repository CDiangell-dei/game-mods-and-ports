local function onComplete() end

local introComplete = game.data.getProgress('intro_complete')
if introComplete == 1 then
    local modeSelector = require('data/scripts/game_selector.lua')
    modeSelector.init(onComplete)
else
    local modeSelector = require('data/scripts/cutscene_initializer.lua')
    modeSelector.init(onComplete)
end
