-- Gema da Vida (Balance): mecanica nova.
--   * destruir 10 itens deixa a gema PRONTA (vender nao conta)
--   * pronta + perder uma batalha com a barra a pelo menos 50% de progresso: nao perde a vida
--   * depois de absorver: 50% de chance de quebrar; senao o contador zera (precisa de 10 de novo)
--
-- Pontos importantes:
--   * o evento onBeforeLifeLoss vem de game_control.endGame, so no FIM de uma batalha perdida e
--     so se nao houver escudo (a Boneca vem primeiro). Durante a batalha a gema nunca ativa.
--   * ficar pronta so mostra a animacao do item (sem som de cura); o som toca ao absorver a derrota.
--   * a chefe das fadas troca a gema por lifegem_off (apagada); o texto dela e o script estao em
--     lifegem_off.lua e o texto em lifegem_off_description.
local lifegem = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _wasSold = false
local _counter = 0

local function _isReady()
    return _counter >= lifegem.data.amount
end

function lifegem.getVar(variableName)
    local data = lifegem.data
    if variableName == 'progress' then
        return math.min(_counter, data.amount)
    elseif variableName == 'remaining' then
        return math.max(0, data.amount - _counter)
    elseif variableName == 'amount' then
        return data.amount
    elseif variableName == 'tolerancePercent' then
        return data.tolerance * 100
    elseif variableName == 'breakChance' then
        return data.breakChance
    end
    return nil
end

function lifegem.onRemoveTile(_)
    if _wasSold then
        _wasSold = false
        return
    end
    if _isReady() then
        return
    end
    _counter = _counter + 1
    if _isReady() then
        game.control.ui.triggerTile(lifegem.index)
    end
end

function lifegem.onSellTile(_)
    _wasSold = true
end

-- progresso da batalha perdida, de 0 a 1 (1 = barra cheia)
local function _battleProgress()
    local battle = game.control.encounter
    if battle == nil or battle.requiredExhaustion == nil or battle.requiredExhaustion <= 0 then
        return nil
    end
    return battle.exhaustion / battle.requiredExhaustion
end

function lifegem.onBeforeLifeLoss(info)
    if info.absorbed or not _isReady() then
        return
    end
    local progress = _battleProgress()
    if progress == nil or progress < (1 - lifegem.data.tolerance) then
        return
    end
    info.absorbed = true
    _counter = 0
    game.audio.playSound('data/sounds/general/heal.json')
    game.control.ui.triggerTile(lifegem.index)
    if math.random() * 100 < lifegem.data.breakChance then
        game.control.tiles.destroyTile(lifegem.index)
        game.audio.playSound('data/sounds/general/tile_super.json')
    end
end

return lifegem
