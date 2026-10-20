-- Bolsa de Brinquedos sem Fundo (Balance): ao entrar na loja perde 50% do bonus acumulado
-- (antes zerava tudo). O corte acontece uma unica vez por entrada na loja.
local bottomlessBagToys = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _flatModifier = 0
local _lastCutFloor = -1 -- andar da ultima loja em que o corte foi aplicado (evita corte duplo)

local function _calculateExhaustion()
    local amount = bottomlessBagToys.data.exhaustion + bottomlessBagToys.flatModifier + _flatModifier
    return math.max(0, amount * bottomlessBagToys.percentageModifier)
end

function bottomlessBagToys.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return bottomlessBagToys.data.increase
    elseif variableName == 'cutPercent' then
        return bottomlessBagToys.data.cutPercent
    end
    return nil
end

function bottomlessBagToys.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, bottomlessBagToys)
end

function bottomlessBagToys.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        game.control.ui.triggerTile(bottomlessBagToys.index, true)
        _flatModifier = _flatModifier + bottomlessBagToys.data.increase
    end
    if encounterType == 'shop' then
        local floor = game.control.getFloorCount()
        if _lastCutFloor == floor then
            return -- esta loja ja cortou o bonus
        end
        _lastCutFloor = floor
        game.control.ui.triggerTile(bottomlessBagToys.index, true)
        _flatModifier = _flatModifier * (1 - bottomlessBagToys.data.cutPercent / 100)
    end
end

return bottomlessBagToys
