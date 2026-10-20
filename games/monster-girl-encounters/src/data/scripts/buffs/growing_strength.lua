local growingStrength = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _increase = 0
local _isBattle = false
local _duration

local function _calculateModifier()
    return growingStrength.data.modifier + _increase
end

function growingStrength.init()
    _duration = growingStrength.data.duration
end

function growingStrength.getVar(variableName)
    if variableName == 'modifier' then
        return _calculateModifier()
    elseif variableName == 'increase' then
        return growingStrength.data.increase
    elseif variableName == 'duration' then
        return _duration
    end
end

function growingStrength.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion * _calculateModifier()
    table.insert(pumpData.pumpers, growingStrength)
end

function growingStrength.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'elite' or encounterType == 'boss' then
        _isBattle = true
        _increase = _increase + growingStrength.data.increase
    end
end

function growingStrength.onExitEncounter()
    if not _isBattle then
        return
    end
    _isBattle = false
    _duration = _duration - 1
    if _duration <= 0 then
        game.control.buffs.remove(growingStrength)
    end
end

return growingStrength
