-- Rich Mode: ouro maximo ao iniciar uma partida nova.
-- Hook usado: onRunStarted (game_selector). Nao roda ao continuar um save.
local hooks = {}

local START_GOLD = 1000000

function hooks.onRunStarted(control)
    -- gainGold ja respeita o teto atual do jogo (999.999, ou o teto do mod No Limit)
    control.gainGold(math.min(START_GOLD, control.getMaxGold()))
end

return { hooks = hooks }
