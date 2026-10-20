local _mods = require('mods/mod_manager.lua') -- MOD

local battle = {
    exhaustion = 0,
    requiredExhaustion = 100,
    ui = dofile('data/scripts/ui/battle.lua'),
    isElite = false,
    --eventSpawner = dofile('data/scripts/buff_event_spawner.lua'), --too distracting from dialogue, consider adding back in later
}

local _isBattleState = false

-- MOD: used by mods (ex: skip_battle) to know if a battle is still running
function battle.isBattleActive()
    return _isBattleState
end

local function _calculateRequiredExhaustion(pumpCount)
    local floor = game.control.getFloorCount() + 1
    --local itemCount = floor * 2.0
    --itemCount = math.min(itemCount, 16)
    local a = 1.58
    local b = 10.0
    local c = 2.42
    local perItem = (a ^ floor) + (b * floor) + c
    local loop = math.floor((floor - 1) / 13)
    -- MOD: mods can scale the requirement (endless_mode uses this for the loops)
    perItem = _mods.filter('requiredExhaustionPerItem', perItem, loop)
    --return perItem * itemCount * pumpCount
    -- MOD: a^floor can overflow to inf on very high floors; mods can keep it finite
    return _mods.filter('sanitizeNumber', perItem * pumpCount, 'required')
end

function battle.init()
    battle.ui.instantiate()
end

function battle.forcePopEvent()
    --battle.eventSpawner.pop()
end

function battle.onDestroy()
    --battle.eventSpawner.destroy()
    battle.ui.destroy()
end

function battle.pump(exhaustionData)
    -- MOD: pumpExhaustion lets mods change the final EPP of a pump (hack_mode);
    -- sanitizeNumber keeps the numbers finite (no_limit)
    exhaustionData.exhaustion = _mods.filter('pumpExhaustion', exhaustionData.exhaustion, battle, exhaustionData)
    exhaustionData.exhaustion = _mods.filter('sanitizeNumber', exhaustionData.exhaustion, 'exhaustion')
    battle.exhaustion = _mods.filter('sanitizeNumber', battle.exhaustion + exhaustionData.exhaustion, 'exhaustion')
    battle.ui.pump(exhaustionData)
end

function battle.startBattle(pumpCount)
    battle.requiredExhaustion = _calculateRequiredExhaustion(pumpCount)
    battle.exhaustion = 0

    --TESTING WIN
    --battle.requiredExhaustion = 1
    --battle.exhaustion = 1
    --END TESTING

    --local parent = game.object.getRoot().find('main/viewport')
    --battle.eventSpawner.init(parent)
    _isBattleState = true
    battle.ui.resumeBattle()
    _mods.call('onBattleStarted', battle) -- MOD: skip_battle lives in mods/list/skip_battle
end

function battle.stopBattle()
    --battle.eventSpawner.destroy()
    battle.ui.stopBattle()
    _isBattleState = false
end

function battle.shouldSkipIntro()
    local skip = game.data.getSetting('skipAlreadySeen')
    if skip ~= 1 then
        return false
    end
    local hasWon = game.data.getProgress('win_' .. game.control.encounterData.key) == 1
    local hasLost = game.data.getProgress('lose_' .. game.control.encounterData.key) == 1
    if hasWon or hasLost then
        return true
    end
end

function battle.shouldSkipOutro(isFail)
    local skip = game.data.getSetting('skipAlreadySeen')
    if skip ~= 1 then
        return false
    end
    if isFail then
        return game.data.getProgress('lose_' .. game.control.encounterData.key) == 1
    else
        return game.data.getProgress('win_' .. game.control.encounterData.key) == 1
    end
end

local function _triggerIfNewBattle()
    local lost = game.data.getProgress('lose_' .. game.control.encounterData.key)
    local won = game.data.getProgress('win_' .. game.control.encounterData.key)
    if won or lost then
        return
    end
    game.control.trigger('newBattleSeen')
end

function battle.complete(profit)
    _triggerIfNewBattle()
    local isFail = battle.exhaustion < battle.requiredExhaustion
    if isFail then
        battle.ui.setAnimatorSpeed(0)
        game.data.setProgress('lose_' .. game.control.encounterData.key, 1)
        game.control.trigger('onLoseBattle')
        game.control.endGame()
    elseif game.control.isFinalFloor() then
        if game.data.getSetting('gameMode') < 0.5 then
            game.data.setProgress('standard_complete', 1)
        end
        game.data.setProgress('win_' .. game.control.encounterData.key, 1)
        game.control.trigger('onWinBattle')
        game.control.completeEncounter()
    else
        local level = game.control.getFloorCount()
        profit = (0.5 + (level * 0.2)) * profit
        profit = _mods.filter('sanitizeNumber', profit, 'gold') -- MOD
        profit = math.floor(profit)
        profit = math.max(0, profit)
        profit = math.min(game.control.getMaxGold(), profit) -- MOD: same cap as the gold
        local function callback()
            game.data.setProgress('win_' .. game.control.encounterData.key, 1)
            game.control.gainGold(profit)
            game.control.trigger('onWinBattle')
            
            local isEndless = game.data.getSetting('gameMode') > 0.5
            local isBoss = (game.control.encounterData ~= nil and game.control.encounterData.key == 'boss_fairies')
            if isEndless and isBoss then
                local reward = dofile('data/scripts/ui/cycle_reward.lua')
                reward.init(function()
                    game.control.completeEncounter()
                end)
            else
                game.control.completeEncounter()
            end
        end
        local itemRoller = dofile('data/scripts/encounters/elite_reward_roller.lua')
        local item = itemRoller.getRandomItem(battle.isElite)
        battle.ui.gainReward(profit, callback, item)
    end
end

function battle.update(deltaTime)
    if not _isBattleState then
        battle.ui.update(deltaTime)
        return
    end
    --battle.eventSpawner.update(deltaTime)
    battle.ui.update(deltaTime)
end

return battle
