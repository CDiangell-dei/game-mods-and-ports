-- Bolsa de Brinquedos (Balance): alem do efeito original, cada OUTRA Bolsa de Brinquedos no
-- inventario da +5 de fadiga a esta (reciproco: com 3 bolsas, cada uma recebe +10).
local bagOfToys = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _flatModifier = 0

local function _countOtherBags()
    local count = 0
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    for x = 1, width do
        for y = 1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile.data.key == 'bag_of_toys' and index ~= bagOfToys.index then
                count = count + 1
            end
        end
    end
    return count
end

local function _calculateExhaustion()
    local synergy = _countOtherBags() * bagOfToys.data.synergy
    local amount = bagOfToys.data.exhaustion + bagOfToys.flatModifier + _flatModifier + synergy
    return math.max(0, amount * bagOfToys.percentageModifier)
end

function bagOfToys.getVar(variableName)
    if variableName == 'exhaustion' then
        return _calculateExhaustion()
    elseif variableName == 'increase' then
        return bagOfToys.data.increase
    elseif variableName == 'synergy' then
        return bagOfToys.data.synergy
    end
    return nil
end

function bagOfToys.pump(pumpData)
    local amount = _calculateExhaustion()
    pumpData.exhaustion = pumpData.exhaustion + amount
    table.insert(pumpData.pumpers, bagOfToys)
end

function bagOfToys.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        game.control.ui.triggerTile(bagOfToys.index, true)
        _flatModifier = _flatModifier + bagOfToys.data.increase
    end
end

return bagOfToys
