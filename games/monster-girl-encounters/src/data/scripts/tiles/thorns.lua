local thorns = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _isActive = false

function thorns.getVar(variableName)
    if variableName == 'modifier' then
        return thorns.data.modifier
    end
    return nil
end

function thorns.pump(pumpData)
    if not _isActive then
        return
    end
    pumpData.exhaustion = pumpData.exhaustion * thorns.data.modifier
    table.insert(pumpData.pumpers, thorns)
end

function thorns.onEnterEncounter(encounterType)
    _isActive = (encounterType == 'boss' or encounterType == 'elite')
    if _isActive then
        game.control.ui.triggerTile(thorns.index, true)
    end
end

return thorns
