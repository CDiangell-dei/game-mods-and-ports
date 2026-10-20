local buffSlime = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _copied = nil

local function _callCopy(functionName, ...)
    if _copied == nil then
        return false
    end
    if _copied[functionName] ~= nil then
        _copied[functionName](...)
        return true
    end
    return false
end

local function _getRandomBuff()
    local count = game.control.buffs.getCount()
    local roll = math.random(count)
    return game.control.buffs.getBuff(roll)
end

function buffSlime.getVar(variableName)
    if variableName ~= 'current' then
        return nil
    end
    if _copied == nil then
        return 'no_item'
    else
        return _copied.data.name
    end
end

function buffSlime.onDestroy()
    _callCopy('onDestroy')
    _copied = nil
end

function buffSlime.update(deltaTime)
    _callCopy('update', deltaTime)
end

function buffSlime.pump(pumpData)
    if _callCopy('pump', pumpData) then
        table.insert(pumpData.pumpers, buffSlime)
    end
end

function buffSlime.onEnterEncounter(encounterType)
    if encounterType ~= 'battle' and encounterType ~= 'boss' and encounterType ~= 'elite' then
        return
    end
    local copiedBuff = _getRandomBuff()
    if copiedBuff == nil then
        return
    end
    game.control.ui.triggerTile(buffSlime.index, true)
    local copiedTable = dofile(copiedBuff.data.script)
    copiedTable._index = 0
    for k, v in pairs(copiedBuff) do
        if k ~= 'index' and type(v) ~= 'function' and type(v) ~= 'table' then
            copiedTable[k] = v
        end
    end
    copiedTable.data = copiedBuff.data
    _copied = copiedTable
end

function buffSlime.onLoseBattle()
    _callCopy('onLoseBattle')
end

function buffSlime.onExitEncounter()
    _callCopy('onExitEncounter')
    _callCopy('onDestroy')
    _copied = nil
end

function buffSlime.onExitGame()
    buffSlime.onExitEncounter()
end

function buffSlime.onGainGold(amount)
    _callCopy('onGainGold', amount)
end

function buffSlime.onLoseGold(amount)
    _callCopy('onLoseGold', amount)
end

function buffSlime.onAddTile(tile)
    _callCopy('onAddTile', tile)
end

function buffSlime.onRemoveTile(tile)
    _callCopy('onRemoveTile', tile)
end

function buffSlime.onInventoryChange()
    _callCopy('onInventoryChange')
end

function buffSlime.onAddPerk(perk)
    _callCopy('onAddPerk', perk)
end

function buffSlime.onRemovePerk(perk)
    _callCopy('onRemovePerk', perk)
end

function buffSlime.onAddBuff(buff)
    _callCopy('onAddBuff', buff)
end

function buffSlime.onRemoveBuff(buff)
    _callCopy('onRemoveBuff', buff)
end

function buffSlime.onPurchase(itemData)
    _callCopy('onPurchase', itemData)
end

function buffSlime.onRerollShop()
    _callCopy('onRerollShop')
end

return buffSlime
