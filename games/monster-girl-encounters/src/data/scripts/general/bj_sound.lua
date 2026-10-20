local persist = require('data/scripts/general/bj_persistent.lua')
--[[local slurpIndex = persist.bjSlurp or 0
slurpIndex = slurpIndex + 1
if slurpIndex > 11 then
    persist.bjSlurp = math.random(0, 3)
    game.audio.playSound('data/sounds/sex/bj_slurp.json')
    return
end
persist.bjSlurp = slurpIndex]]--
local index = persist.bjIndex or 0
index = index + 1
if index == 5 then
    index = 1
end
persist.bjIndex = index
if index == 1 then
    game.audio.playSound('data/sounds/sex/bj_up1.json')
elseif index == 2 then
    game.audio.playSound('data/sounds/sex/bj_down1.json')
elseif index == 3 then
    game.audio.playSound('data/sounds/sex/bj_up2.json')
else
    game.audio.playSound('data/sounds/sex/bj_down2.json')
end
