-- Idolo Dourado (Balance): bonus de ouro logaritmico, desgaste por pump e custo (gold_scaling.lua).
-- Efeito base (+8 de fadiga) preservado; so a parcela que vem do ouro e freada.
local goldenIdol = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _scaling = require('mods/list/balance/gold_scaling.lua')

-- gold = ouro de referencia, uses = ativacoes ja feitas nesta batalha
local function _calculateExhaustion(gold, uses)
    local data = goldenIdol.data
    local bonus = _scaling.growth(gold, data.amplitude, data.scale) * _scaling.wear(uses)
    local amount = data.exhaustion + goldenIdol.flatModifier + bonus
    return math.max(0, amount * goldenIdol.percentageModifier)
end

function goldenIdol.getVar(variableName)
    if variableName == 'exhaustion' then
        -- valor da PROXIMA ativacao (ouro atual e desgaste atual)
        return _calculateExhaustion(game.control.getGold(), _scaling.uses('golden_idol'))
    elseif variableName == 'decayPercent' then
        return _scaling.DECAY_MAX * 100
    elseif variableName == 'maxCostPercent' then
        return _scaling.MAX_COST_FRACTION * 100
    end
    return nil
end

function goldenIdol.pump(pumpData)
    local gold, uses = _scaling.activate('golden_idol', pumpData) -- cobra o custo
    pumpData.exhaustion = pumpData.exhaustion + _calculateExhaustion(gold, uses)
    table.insert(pumpData.pumpers, goldenIdol)
end

return goldenIdol
