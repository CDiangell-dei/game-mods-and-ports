-- Gema da Vida apagada (Balance): vira isto quando o jogo a apaga (chefe das fadas / evento de
-- perda de vida). Enquanto estiver apagada nao faz nada, mas VOLTA A FUNCIONAR quando o jogador
-- vence a chefe. Todas as variaveis de texto respondem para nunca aparecer <var=...>.
local lifegem = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

function lifegem.getVar(variableName)
    if variableName == 'remaining' or variableName == 'progress' then
        return 0
    elseif variableName == 'amount' then
        return lifegem.data.amount
    end
    return nil
end

-- Vencer a chefe (boss_*) acende a gema de novo: ela volta como uma Gema da Vida nova (contador em 0).
function lifegem.onWinBattle()
    local encounterData = game.control.encounterData
    if encounterData == nil or encounterData.key == nil or not string.find(encounterData.key, '^boss_') then
        return
    end
    local data = require('data/scripts/data.lua')
    local index = lifegem.index
    game.control.tiles.setTile(index, data.tiles['lifegem'])
    game.audio.playSound('data/sounds/general/heal.json')
    game.control.ui.triggerTile(index)
end

return lifegem
