-- Idolo Dourado e Elixir Dourado: como o ouro vira bonus (Balance).
--
-- Tres freios, todos de crescimento/penalidade (nenhum teto fixo no dano ou no multiplicador):
--
--  1) CRESCIMENTO LOGARITMICO. O bonus original era linear no ouro (ouro * increase). Agora e
--       bonus(G) = A * ln(1 + G / S)           com  A / S = increase original
--     Com pouco ouro e igual ao original (ln(1+x) ~ x); com muito ouro cresce bem devagar.
--
--  2) DESGASTE SUAVE DO BONUS. Durante a batalha o bonus de ouro perde, no maximo, 30% do valor
--     inicial, e perde cada vez mais devagar (curva hiperbolica):
--       wear(n) = 0.70 + 0.30 / (1 + n / 15)       n = ativacoes do item na batalha
--     n=0: 100%   n=15: 85%   n=45: 77.5%   n->infinito: 70%. Reinicia a cada batalha.
--     O resto do freio vem do custo em ouro (3), que reduz o proprio ouro.
--
--  3) CUSTO EM OURO POR ATIVACAO, funcao continua do ouro (sem regra de faixa):
--       u = (G / 200000) ^ 2 * (1 + n / 10)
--       fracao = 1.5% * u / (1 + u)               (sempre menor que 1.5%)
--     Com pouco ouro u e minusculo (10.000 de ouro: 0.004% do ouro, praticamente de graca);
--     quanto mais ouro, mais pesa; com muito ouro a fracao chega perto de 1.5%. Cada pump a mais na
--     batalha aumenta u (o custo sobe devagar). A SOMA dos custos de todos os itens no mesmo pump
--     tambem nunca passa de 1.5% do ouro que o jogador tinha antes do pump.
--
-- G e o ouro ANTES do pump (guardado uma vez por pump). O modulo e compartilhado (require e
-- cacheado), entao os dois itens usam a mesma referencia e o mesmo limite de custo.
--
-- Lembrete: o sandbox do jogo so tem math.log (nao existe math.log10).
local scaling = {}

scaling.DECAY_MAX = 0.30          -- maximo que o desgaste tira do bonus de ouro
scaling.DECAY_TAU = 15            -- ativacoes ate o desgaste chegar na metade do maximo
scaling.MAX_COST_FRACTION = 0.015 -- 1.5% do ouro por pump, somando todos os itens
scaling.COST_SCALE = 200000       -- ouro em que u = 1 (fracao de custo na metade do maximo)
scaling.COST_POWER = 2            -- quao forte o custo cai para quem tem pouco ouro
scaling.COST_GROWTH_TAU = 10      -- ativacoes para dobrar u

local _encounter = nil
local _uses = {}            -- chave do item -> ativacoes na batalha atual
local _pumpData = nil
local _referenceGold = 0
local _chargedThisPump = 0

-- cada batalha e um objeto novo em game.control.encounter: contagem reinicia sozinha
local function _syncBattle()
    if game.control.encounter ~= _encounter then
        _encounter = game.control.encounter
        _uses = {}
    end
end

function scaling.uses(key)
    _syncBattle()
    return _uses[key] or 0
end

-- 1) crescimento logaritmico: A * ln(1 + G / S)
function scaling.growth(gold, amplitude, scale)
    if gold < 0 then
        gold = 0
    end
    return amplitude * math.log(1 + gold / scale)
end

-- 2) fator de desgaste depois de n ativacoes: de 1 ate (1 - DECAY_MAX), cada vez mais devagar
function scaling.wear(uses)
    return (1 - scaling.DECAY_MAX) + scaling.DECAY_MAX / (1 + uses / scaling.DECAY_TAU)
end

-- 3) fracao e custo em ouro
function scaling.costFraction(gold, uses)
    if gold <= 0 then
        return 0
    end
    local u = ((gold / scaling.COST_SCALE) ^ scaling.COST_POWER) * (1 + uses / scaling.COST_GROWTH_TAU)
    return scaling.MAX_COST_FRACTION * u / (1 + u)
end

function scaling.cost(gold, uses)
    return math.floor(gold * scaling.costFraction(gold, uses))
end

-- ouro de referencia: lido uma vez por pump (cada pump cria uma tabela pumpData nova)
local function _referenceFor(pumpData)
    if pumpData ~= _pumpData then
        _pumpData = pumpData
        _referenceGold = game.control.getGold()
        _chargedThisPump = 0
    end
    return _referenceGold
end

-- Registra uma ativacao do item: devolve o ouro de referencia (G) e quantas vezes o item ja
-- tinha ativado nesta batalha (n), e cobra o custo respeitando 1.5% do ouro por pump.
function scaling.activate(key, pumpData)
    local gold = _referenceFor(pumpData)
    local uses = scaling.uses(key)
    local cost = scaling.cost(gold, uses)
    local room = math.floor(gold * scaling.MAX_COST_FRACTION) - _chargedThisPump
    if cost > room then
        cost = math.max(room, 0)
    end
    if cost > 0 then
        game.control.loseGold(cost)
        _chargedThisPump = _chargedThisPump + cost
    end
    _uses[key] = uses + 1
    return gold, uses, cost
end

return scaling
