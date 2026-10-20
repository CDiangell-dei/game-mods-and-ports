local alchemicalOrb = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

function alchemicalOrb.getVar(variableName)
    if variableName == 'amount' then
        return alchemicalOrb.data.amount
    end
end

function alchemicalOrb.onEnterEncounter(encounterType)
    local gold = game.control.getGold()
    if gold < 1 then
        return
    end
    local interest = gold * alchemicalOrb.data.amount * 0.01
    interest = math.floor(interest)
    interest = math.max(1, interest)
    game.control.gainGold(interest)
    game.audio.playSound('data/sounds/general/purchase.json')
    game.control.ui.triggerTile(alchemicalOrb.index)
end

return alchemicalOrb
