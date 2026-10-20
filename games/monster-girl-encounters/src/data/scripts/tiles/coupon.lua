local coupon = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

function coupon.getVar(variableName)
    if variableName == 'amount' then
        return coupon.data.amount
    end
end

function coupon.onEnterEncounter(encounterType)
    if encounterType == 'shop' then
        game.control.encounter.increaseCostModifier(-(coupon.data.amount * 0.01))
    end
end

return coupon
