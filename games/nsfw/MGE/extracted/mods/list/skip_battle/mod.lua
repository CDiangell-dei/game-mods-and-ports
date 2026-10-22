-- Skip Battles: painel com check na area central da tela (auto_battle.json) + resolucao
-- automatica das batalhas. Fica dentro da area central, longe do inventario.
-- Era codigo do jogo base (game_main.lua e battle.lua); agora vive aqui e e ligado por hooks.
local MOD = require('mods/mod_manager.lua').current()
local hooks = {}

local function _isAvailable()
    return true
end

-- Hook de game_main.lua: cria o toggle dentro da tela da partida
function hooks.onMainUiReady(parent)
    if not _isAvailable() then
        return
    end
    local autoBattle = game.object.instantiate(MOD.folder .. 'auto_battle.json', parent)
    local toggle = dofile('data/scripts/ui/default_toggle.lua')
    toggle.init(autoBattle.find('toggle'), nil)
    toggle.setIsOn(game.data.getSetting('autoBattle') > 0.5)
    toggle.onToggle.subscribe(function(isOn)
        game.data.setSetting('autoBattle', isOn and 1 or 0)
    end)
end

local function _resolveAutomatically(battle)
    local pumpCount = battle.ui.getSimulatedPumpCount(60)
    for _ = 1, pumpCount do
        game.control.trigger('pump', { exhaustion = 0, pumpers = {} })
    end
    return battle.exhaustion / battle.requiredExhaustion
end

-- Hook de battle.lua (startBattle): agenda a resolucao automatica
function hooks.onBattleStarted(battle)
    if not _isAvailable() or game.data.getSetting('autoBattle') <= 0.5 then
        return
    end
    local resolved = false
    game.timer.queue(0.75, function()
        if battle.isBattleActive() and not resolved then
            resolved = true
            game.control.ui.fadeIn(function()
                local multiplier = game.control.encounterData.autoBattleProfitMultiplier or 1
                local progress = _resolveAutomatically(battle)
                battle.stopBattle()
                battle.complete(progress * 10 * multiplier)
            end)
        end
    end)
end

return { hooks = hooks }
