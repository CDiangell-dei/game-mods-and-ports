local blackCard = {
    --Other scripts can modify these for this script to use to modify its output
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _isInShop = false
local _isFree = false

local function _enableShop()
    if _isInShop then
        return
    end
    _isInShop = true
    game.control.encounter.increaseRerollModifier(-(blackCard.data.reduce * 0.01))
    _isFree = true
    game.control.encounter.increaseCostModifier(-999)
end

local function _disableShop()
    if not _isInShop then
        return
    end
    _isInShop = false
    _isFree = false
    game.control.encounter.increaseRerollModifier(blackCard.data.reduce * 0.01)
end

function blackCard.init()
    game.control.luck = game.control.luck + blackCard.data.luckIncrease
    if game.control.encounterType == 'shop' then
        _enableShop()
    end
end

function blackCard.onDestroy()
    game.control.luck = game.control.luck - blackCard.data.luckIncrease
    _disableShop()
end

function blackCard.getVar(variableName)
    if variableName == 'reduce' then
        return blackCard.data.reduce
    elseif variableName == 'luckIncrease' then
        return blackCard.data.luckIncrease
    end
end

function blackCard.onPurchase(_)
    if _isFree then
        _isFree = false
        game.control.encounter.increaseCostModifier(999)
    end
end

function blackCard.onEnterEncounter(encounterType)
    if encounterType == 'shop' then
        _enableShop()
    end
end

return blackCard
