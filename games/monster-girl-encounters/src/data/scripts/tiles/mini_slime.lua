local miniSlime = {
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

local function _getRandomTile()
    local width = game.control.tiles.getWidth()
    local height = game.control.tiles.getHeight()
    local count = 1
    for x=1, width do
        for y=1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile.data ~= miniSlime.data then
                count = count + 1
            end
        end
    end
    local roll = math.random(count)
    local lastTile = nil
    for x=1, width do
        for y=1, height do
            local index = game.control.tiles.getIndex(x, y)
            local tile = game.control.tiles.getTile(index)
            if tile ~= nil and tile.data ~= miniSlime.data then
                roll = roll - 1
                if roll <= 0 then
                    return tile
                end
                lastTile = tile
            end
        end
    end
    return lastTile
end

function miniSlime.getVar(variableName)
    if variableName ~= 'current' then
        return nil
    end
    if _copied == nil then
        return 'no_item'
    else
        return _copied.data.name
    end
end

function miniSlime.onDestroy()
    _callCopy('onDestroy')
    _copied = nil
end

function miniSlime.update(deltaTime)
    if _copied ~= nil then
        _copied.index = miniSlime.index
    end
    _callCopy('update', deltaTime)
end

function miniSlime.pump(pumpData)
    if _callCopy('pump', pumpData) then
        table.insert(pumpData.pumpers, miniSlime)
    end
end

function miniSlime.onEnterEncounter(encounterType)
    if encounterType ~= 'battle' and encounterType ~= 'boss' and encounterType ~= 'elite' then
        return
    end
    local copiedTile = _getRandomTile()
    if copiedTile == nil then
        return
    end
    game.control.ui.triggerTile(miniSlime.index, true)
    local copiedTable = dofile(copiedTile.data.script)
    copiedTable.index = miniSlime.index
    for k, v in pairs(copiedTile) do
        if k ~= 'index' and type(v) ~= 'function' and type(v) ~= 'table' then
            copiedTable[k] = v
        end
    end
    copiedTable.data = copiedTile.data
    if copiedTable.init ~= nil then
        copiedTable.init()
    end
    _copied = copiedTable
end

function miniSlime.onLoseBattle()
    _callCopy('onLoseBattle')
end

function miniSlime.onExitEncounter()
    _callCopy('onExitEncounter')
    _callCopy('onDestroy')
    _copied = nil
end

function miniSlime.onExitGame()
    miniSlime.onExitEncounter()
end

function miniSlime.onGainGold(amount)
    _callCopy('onGainGold', amount)
end

function miniSlime.onLoseGold(amount)
    _callCopy('onLoseGold', amount)
end

function miniSlime.onAddTile(tile)
    _callCopy('onAddTile', tile)
end

function miniSlime.onRemoveTile(tile)
    _callCopy('onRemoveTile', tile)
end

function miniSlime.onInventoryChange()
    _callCopy('onInventoryChange')
end

function miniSlime.onAddPerk(perk)
    _callCopy('onAddPerk', perk)
end

function miniSlime.onRemovePerk(perk)
    _callCopy('onRemovePerk', perk)
end

function miniSlime.onAddBuff(buff)
    _callCopy('onAddBuff', buff)
end

function miniSlime.onRemoveBuff(buff)
    _callCopy('onRemoveBuff', buff)
end

function miniSlime.onPurchase(itemData)
    _callCopy('onPurchase', itemData)
end

function miniSlime.onRerollShop()
    _callCopy('onRerollShop')
end

return miniSlime
