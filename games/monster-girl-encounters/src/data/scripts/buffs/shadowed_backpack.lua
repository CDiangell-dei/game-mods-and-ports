local shadowedBackpack = {
    --Other scripts can modify these for this script to use to modify its output
    exhaustionModifier = 1.0,
}

local _isShop = false

function shadowedBackpack.init()
    for _ = 1, 50 do
        game.control.tiles.addRow()
    end
end

function shadowedBackpack.getVar(variableName)
    if variableName == 'reduction' then
        return shadowedBackpack.data.reduction
    end
end

function shadowedBackpack.onEnterEncounter(encounterType)
    if encounterType == 'shop' then
        game.control.encounter.increaseCostModifier(-shadowedBackpack.data.reduction * 0.01)
        _isShop = true
    end
end

function shadowedBackpack.onExitEncounter()
    if not _isShop then
        return
    end
    for _ = 1, 50 do
        game.control.tiles.removeRow()
    end
    game.control.buffs.remove(shadowedBackpack)
end

return shadowedBackpack
