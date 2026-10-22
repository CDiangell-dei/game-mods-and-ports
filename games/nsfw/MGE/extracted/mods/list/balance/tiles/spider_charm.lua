-- Amuleto da Aranha (Balance): a cada rerrolagem
--   1) ganha +5 de sorte (efeito original, sempre)
--   2) depois, a sorte muda em PORCENTAGEM da sorte atual:
--        33% de chance: +5%    5% de chance: -10%    62%: nada.   A sorte nunca fica abaixo de 5.
local spiderCharm = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

function spiderCharm.getVar(variableName)
    local data = spiderCharm.data
    if variableName == 'amount' then
        return data.amount
    elseif variableName == 'upChance' then
        return data.upChance
    elseif variableName == 'upPercent' then
        return data.upPercent
    elseif variableName == 'downChance' then
        return data.downChance
    elseif variableName == 'downPercent' then
        return data.downPercent
    elseif variableName == 'minLuck' then
        return data.minLuck
    end
    return nil
end

function spiderCharm.onRerollShop()
    local data = spiderCharm.data
    -- 1) efeito original: +5 de sorte
    local luck = game.control.luck + data.amount
    -- 2) efeito novo, sobre a sorte atual (ja com os +5)
    local roll = math.random() * 100
    if roll < data.upChance then
        luck = math.max(luck * (1 + data.upPercent / 100), data.minLuck)
    elseif roll < data.upChance + data.downChance then
        if luck > data.minLuck then
            luck = math.max(luck * (1 - data.downPercent / 100), data.minLuck)
        end
    end
    game.control.luck = luck
    game.control.ui.triggerTile(spiderCharm.index, true)
end

return spiderCharm
