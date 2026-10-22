local datedCertificate = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _decrease = 0

local function _calculateModifier()
    local modifier = datedCertificate.data.modifier - _decrease
    return math.max(0, modifier)
end

function datedCertificate.getVar(variableName)
    --used for variables in tooltips
    if variableName == 'modifier' then
        return _calculateModifier()
    elseif variableName == 'decrease' then
        return datedCertificate.data.decrease
    end
end

function datedCertificate.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion * _calculateModifier()
    table.insert(pumpData.pumpers, datedCertificate)
end

function datedCertificate.onEnterEncounter(encounterType)
    if encounterType == 'shop' then
        game.control.ui.triggerTile(datedCertificate.index, true)
        _decrease = _decrease + datedCertificate.data.decrease
    end
end

return datedCertificate
