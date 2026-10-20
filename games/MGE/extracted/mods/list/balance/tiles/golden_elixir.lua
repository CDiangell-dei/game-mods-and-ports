-- Elixir Dourado (Balance): bonus de ouro logaritmico, desgaste por pump e custo (gold_scaling.lua).
-- Multiplicador base (1x) preservado; so a parcela que vem do ouro e freada. O ouro usado e o de
-- ANTES do pump, entao o bonus ja concedido nao realimenta o proprio calculo.
local goldenElixir = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _scaling = require('mods/list/balance/gold_scaling.lua')

local function _calculateModifier(gold, uses)
    local data = goldenElixir.data
    return data.modifier + (_scaling.growth(gold, data.amplitude, data.scale) * _scaling.wear(uses))
end

function goldenElixir.getVar(variableName)
    if variableName == 'modifier' then
        -- valor da PROXIMA ativacao (ouro atual e desgaste atual)
        return _calculateModifier(game.control.getGold(), _scaling.uses('golden_elixir'))
    elseif variableName == 'decayPercent' then
        return _scaling.DECAY_MAX * 100
    elseif variableName == 'maxCostPercent' then
        return _scaling.MAX_COST_FRACTION * 100
    end
    return nil
end

function goldenElixir.pump(pumpData)
    local gold, uses = _scaling.activate('golden_elixir', pumpData) -- cobra o custo
    pumpData.exhaustion = pumpData.exhaustion * _calculateModifier(gold, uses)
    table.insert(pumpData.pumpers, goldenElixir)
end

return goldenElixir
