-- Hack Mode: EPP infinito em todas as batalhas.
-- "Infinito" aqui = o EPP de cada pump e pelo menos o dobro do que falta para vencer. Assim a
-- barra enche no primeiro pump em qualquer andar, e os numeros continuam finitos (um
-- math.huge de verdade viraria NaN nas barras). Hook usado: pumpExhaustion (encounters/battle.lua).
local hooks = {}

function hooks.pumpExhaustion(value, battle)
    local needed = (battle.requiredExhaustion - battle.exhaustion) * 2
    if needed > value then
        return needed
    end
    return value
end

return { hooks = hooks }
