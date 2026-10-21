-- Enemy Preview: Revela qual monstro ou evento espera em cada bifurcação do mapa.
local hooks = {}

function hooks.isEnemyPreviewActive(_)
    return true
end

return { hooks = hooks }
