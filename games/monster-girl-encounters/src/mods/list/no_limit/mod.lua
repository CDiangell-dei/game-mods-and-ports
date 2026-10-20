-- No Limit: sem teto de ouro e sem quebrar com numeros gigantes.
-- As contas ficam em mods/lib/safe_math.lua. Os pontos do jogo que chamam estes hooks:
--   maxGold            game_control (gainGold / getMaxGold) e battle.complete (lucro)
--   sanitizeNumber     ouro, EPP, exaustao da batalha, requisito, barra de progresso,
--                      numeros exibidos e estatisticas
--   laggingIncrement   contador animado de ouro/EPP na tela
local safe = require('mods/lib/safe_math.lua')
local hooks = {}

local MAX_PROGRESS = 1e9 -- barra de progresso: so precisa saber que passou de 100%

-- sem teto de ouro (o teto real e safe.MAX, para nunca chegar em inf)
function hooks.maxGold(_)
    return safe.MAX
end

-- limpa qualquer numero que entre em ouro / EPP / exaustao / progresso
function hooks.sanitizeNumber(value, kind)
    if type(value) ~= 'number' then
        return value
    end
    if kind == 'progress' then
        if value ~= value then
            return 0
        end
        return math.max(0, math.min(value, MAX_PROGRESS))
    end
    return safe.sanitize(value)
end

-- contador da tela: rapido para numeros grandes e sem travar por falta de precisao
function hooks.laggingIncrement(increment, difference, current)
    return safe.lagStep(increment, difference, current)
end

return { hooks = hooks }
