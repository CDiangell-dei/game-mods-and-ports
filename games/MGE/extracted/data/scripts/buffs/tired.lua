local tired = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _levels = -1
local _isBattle = false

function tired.getVar(variableName)
    if variableName == 'modifier' then
        return tired.data.modifier
    elseif variableName == 'remaining' then
        return tired.data.remaining - _levels
    elseif variableName == 'amount' then
        return tired.data.amount
    end
end

function tired.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'elite' or encounterType == 'boss' then
        _isBattle = true
        game.control.gainGold(tired.data.amount)
        game.audio.playSound('data/sounds/general/purchase.json')
    end
end

function tired.onExitEncounter()
    if not _isBattle then
        return
    end
    _isBattle = false
    _levels = _levels + 1
    if _levels == tired.data.remaining then
        game.control.buffs.remove(tired)
    end
end

function tired.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion * tired.data.modifier
    table.insert(pumpData.pumpers, tired)
end

return tired
