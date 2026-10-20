local paper = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

function paper.getVar(variableName)
    if variableName == 'amount' then
        return paper.data.amount
    end
    return nil
end

function paper.pump(pumpData)
    paper.value = paper.value + paper.data.amount
    table.insert(pumpData.pumpers, paper)
end

return paper
