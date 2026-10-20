local sample = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

function sample.init()
end

function sample.getVar(variableName)
    --used for variables in tooltips
end

function sample.onDestroy()
end

function sample.update(deltaTime)
end

function sample.pump(pumpData)
    pumpData.exhaustion = pumpData.exhaustion + 10.0
    table.insert(pumpData.pumpers, sample)
end

function sample.onEnterEncounter(encounterType)
    --battle, boss, shop, or randomEncounter
end

function sample.onExitEncounter()
end

function sample.onLoseBattle()
end

function sample.onExitGame()
end

function sample.onGainGold(amount)
end

function sample.onLoseGold(amount)
end

function sample.onAddTile(tile)
end

function sample.onRemoveTile(tile)
end

function sample.onInventoryChange()
end

function sample.onAddPerk(perk)
end

function sample.onRemovePerk(perk)
end

function sample.onAddBuff(buff)
end

function sample.onRemoveBuff(buff)
end

function sample.onPurchase(itemData)
end

function sample.onRerollShop()
end

return sample
