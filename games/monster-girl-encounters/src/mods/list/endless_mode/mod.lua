-- Endless Mode: modo de jogo sem fim.
-- Era codigo do jogo base (game_selector, game_control, battle); agora vive aqui via hooks.
local hooks = {}

local function _isEndlessRun()
    return game.data.getSetting('gameMode') > 0.5
end

-- Hook de game_selector.lua: acrescenta o modo na lista (so depois de vencer o Classico)
function hooks.onGameModesBuilt(modes)
    table.insert(modes, {
        name = 'endless_mode',
        description = 'endless_mode_description',
        icon = 'data/sprites/icons/sphinx.png',
        startGame = function()
            game.data.setSetting('gameMode', 1)
            game.control.gainGold(10)
        end,
    })
end

-- Hook de game_control.lua (init): sem limite de andares
function hooks.maxFloors(current)
    if _isEndlessRun() then
        return math.huge
    end
    return current
end

-- Hook de battle.lua: a exigencia cresce 5x a cada ciclo de 13 andares
function hooks.requiredExhaustionPerItem(perItem, loop)
    if _isEndlessRun() then
        return perItem * (5 ^ loop)
    end
    return perItem
end

return { hooks = hooks }
