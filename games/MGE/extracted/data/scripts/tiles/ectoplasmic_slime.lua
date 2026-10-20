local ectoplasmicSlime = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _isShop = false
local _isActive = false

function ectoplasmicSlime.onDestroy()
    if not _isActive then
        return
    end
    for _ = 1, 25 do
        game.control.tiles.addRow()
    end
end

function ectoplasmicSlime.onEnterEncounter(encounterType)
    if encounterType == 'shop' then
        _isShop = true
    end
end

function ectoplasmicSlime.onExitEncounter()
    if _isActive or not _isShop then
        return
    end
    _isShop = false
    _isActive = true
    game.control.ui.triggerTile(ectoplasmicSlime.index)
    for _ = 1, 25 do
        game.control.tiles.removeRow()
    end
end

function ectoplasmicSlime.pump(pumpData)
    if not _isActive then
        return
    end
    table.insert(pumpData.pumpers, ectoplasmicSlime)
    local index = ectoplasmicSlime.index
    for i=1, index - 1 do
        local tile = game.control.tiles.getTile(i)
        if tile ~= nil and tile.pump ~= nil then
            tile.pump(pumpData)
        end
    end
end

return ectoplasmicSlime
