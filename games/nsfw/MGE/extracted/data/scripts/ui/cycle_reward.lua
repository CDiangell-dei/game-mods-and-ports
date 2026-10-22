local cycleReward = {}

local _object = nil

local _allPerks = {
    {
        key = 'bag',
        title = 'cycle_perk_bag',
        desc = 'cycle_perk_bag_desc',
        icon = 'data/sprites/icons/treasure.png',
        apply = function()
            if game.control ~= nil and game.control.tiles ~= nil then
                game.control.tiles.addRow()
            end
        end,
    },
    {
        key = 'life',
        title = 'cycle_perk_life',
        desc = 'cycle_perk_life_desc',
        icon = 'data/sprites/icons/spirit.png',
        apply = function()
            if game.control ~= nil then
                game.control.maxLives = (game.control.maxLives or 3) + 1
                game.control.gainLife()
            end
        end,
    },
    {
        key = 'luck',
        title = 'cycle_perk_luck',
        desc = 'cycle_perk_luck_desc',
        icon = 'data/sprites/icons/sylph.png',
        apply = function()
            if game.control ~= nil then
                game.control.luck = (game.control.luck or 0) + 5
            end
        end,
    },
    {
        key = 'gold',
        title = 'cycle_perk_gold',
        desc = 'cycle_perk_gold_desc',
        icon = 'data/sprites/icons/spider.png',
        apply = function()
            if game.control ~= nil then
                game.control.gainGold(1000)
            end
        end,
    },
}

function cycleReward.init(onComplete)
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end

    local root = game.object.getRoot()
    local parent = root.find('main') or root
    _object = game.object.instantiate('data/scenes/cycle_reward.json', parent)
    game.audio.playSound('data/sounds/general/tile_super.json')

    -- Pick 3 random perks without duplicates
    local indices = { 1, 2, 3, 4 }
    for i = #indices, 2, -1 do
        local j = math.random(i)
        indices[i], indices[j] = indices[j], indices[i]
    end

    local function _selectPerk(perk)
        if perk ~= nil and perk.apply ~= nil then
            pcall(perk.apply)
        end
        game.audio.playSound('data/sounds/general/tile_super.json')
        if _object ~= nil then
            _object.destroy()
            _object = nil
        end
        if onComplete ~= nil then
            onComplete()
        end
    end

    for i = 1, 3 do
        local perk = _allPerks[indices[i]]
        local cardObj = _object.find('panel/card' .. tostring(i))
        if cardObj ~= nil then
            -- Set texts & icon
            local titleComp = cardObj.find('title').getComponent('text')
            if titleComp ~= nil then
                titleComp.setText(game.text.getText(perk.title) or perk.title)
            end
            local descComp = cardObj.find('description').getComponent('text')
            if descComp ~= nil then
                descComp.setText(game.text.getText(perk.desc) or perk.desc)
            end
            game.object.setVisual(cardObj.find('icon'), perk.icon)

            -- Bind Choose Button
            local chooseBtnObj = cardObj.find('chooseButton/button')
            if chooseBtnObj ~= nil then
                local btnComp = chooseBtnObj.getComponent('button')
                if btnComp ~= nil then
                    btnComp.onMouseEnter.subscribe(function()
                        game.audio.playSound('data/sounds/general/mouseover.json', nil, true)
                    end)
                    btnComp.onClick.subscribe(function()
                        _selectPerk(perk)
                    end)
                end
            end

            -- Also bind entire card click
            local cardBtnComp = cardObj.getComponent('button')
            if cardBtnComp ~= nil then
                cardBtnComp.onClick.subscribe(function()
                    _selectPerk(perk)
                end)
            end
        end
    end
end

function cycleReward.destroy()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
end

return cycleReward
