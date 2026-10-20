local _mods = require('mods/mod_manager.lua') -- MOD

-- MOD: sums can reach inf with huge numbers; mods keep them finite
local function _safe(value)
    return _mods.filter('sanitizeNumber', value, 'stat')
end

local statTracker = {
    totalExhaustionDealt = 0, --
    maximumExhaustionPerPump = 0, --
    goldGained = 0, --
    goldSpent = 0, --
    newItems = 0, --
    newBattles = 0, --
    normalBattles = 0, --
    eliteBattles = 0, --
    randomEncounters = 0, --
    shopsEntered = 0, --
    legendaryItems = 0,
    fairiesVisited = 0, --
}

local function _isFairyEncounter(key)
    return key == 'random_sylph' or key == 'random_salamander' or
        key == 'random_undine' or key == 'random_gnome'
end

function statTracker.newBattleSeen()
    statTracker.newBattles = statTracker.newBattles + 1
end

function statTracker.onLoseBattle()
    statTracker.totalExhaustionDealt = _safe(statTracker.totalExhaustionDealt + game.control.encounter.exhaustion)
end

function statTracker.onWinBattle()
    statTracker.totalExhaustionDealt = _safe(statTracker.totalExhaustionDealt + game.control.encounter.exhaustion)
end

function statTracker.onGainGold(amount)
    statTracker.goldGained = _safe(statTracker.goldGained + amount)
end

function statTracker.onRerollShop(cost)
    _mods.call('onGoldSpentInShop', cost) -- MOD: rastreia desbloqueios (mods/unlocks.lua)
    statTracker.goldSpent = _safe(statTracker.goldSpent + cost)
end

function statTracker.onPurchase(data, cost)
    _mods.call('onGoldSpentInShop', cost) -- MOD: rastreia desbloqueios (mods/unlocks.lua)
    statTracker.goldSpent = _safe(statTracker.goldSpent + cost)
end

function statTracker.onObtainNewItem()
    statTracker.newItems = statTracker.newItems + 1
end

function statTracker.onAddTile(tile)
    if tile.data.rarity == 4 then
        statTracker.legendaryItems = statTracker.legendaryItems + 1
    end
end

function statTracker.eppUpdate(epp)
    epp = _safe(epp)
    if epp > statTracker.maximumExhaustionPerPump then
        statTracker.maximumExhaustionPerPump = epp
    end
end

function statTracker.onEnterEncounter(encounterType)
    if encounterType == 'battle' then
        statTracker.normalBattles = statTracker.normalBattles + 1
    elseif encounterType == 'elite' then
        statTracker.eliteBattles = statTracker.eliteBattles + 1
    elseif encounterType == 'shop' then
        statTracker.shopsEntered = statTracker.shopsEntered + 1
    elseif encounterType == 'randomEncounter' then
        statTracker.randomEncounters = statTracker.randomEncounters + 1
        if _isFairyEncounter(game.control.encounterData.key) then
            statTracker.fairiesVisited = statTracker.fairiesVisited + 1
        end
    end
end

game.control.addTriggerReceiver(statTracker)

return statTracker
