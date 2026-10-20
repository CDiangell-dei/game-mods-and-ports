local undineBlessing = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

function undineBlessing.getVar(variableName)
    if variableName == 'modifier' then
        return undineBlessing.data.modifier
    end
end

function undineBlessing.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion * undineBlessing.data.modifier
    table.insert(pumpData.pumpers, undineBlessing)
end

return undineBlessing
