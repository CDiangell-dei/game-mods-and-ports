local cycleReward = {}

local _object = nil

local _allPerks = {
    {
        title = 'cycle_perk_bag',
        desc = 'cycle_perk_bag_desc',
        apply = function()
            if game.control ~= nil and game.control.tiles ~= nil then
                game.control.tiles.addRow()
            end
        end,
    },
    {
        title = 'cycle_perk_life',
        desc = 'cycle_perk_life_desc',
        apply = function()
            if game.control ~= nil then
                game.control.maxLives = (game.control.maxLives or 3) + 1
                game.control.gainLife()
            end
        end,
    },
    {
        title = 'cycle_perk_luck',
        desc = 'cycle_perk_luck_desc',
        apply = function()
            if game.control ~= nil then
                game.control.luck = (game.control.luck or 0) + 5
            end
        end,
    },
    {
        title = 'cycle_perk_gold',
        desc = 'cycle_perk_gold_desc',
        apply = function()
            if game.control ~= nil then
                game.control.gainGold(1000)
            end
        end,
    },
}

function cycleReward.init(onComplete)
    local root = game.object.getRoot()
    _object = game.object.instantiate('data/scenes/cycle_reward.json', root)

    local optionsParent = _object.find('panel/options')

    -- Pick 3 random perks without duplicates
    local indices = { 1, 2, 3, 4 }
    for i = #indices, 2, -1 do
        local j = math.random(i)
        indices[i], indices[j] = indices[j], indices[i]
    end

    for i = 1, 3 do
        local perk = _allPerks[indices[i]]
        local btnObj = game.object.instantiate('data/scenes/mode_selection_item.json', optionsParent)
        btnObj.name = 'perk_' .. tostring(i)

        -- Guarantee 100% opacity (mode_selection_item defaults to 0% dither mask)
        local maskComp = btnObj.getComponent('mask')
        if maskComp ~= nil then
            maskComp.setSprite(game.data.loadSprite('data/sprites/dither/100.png'))
        end

        btnObj.find('title').getComponent('text').setText(game.text.getText(perk.title))
        btnObj.find('description').getComponent('text').setText(game.text.getText(perk.desc))
        game.object.setVisual(btnObj.find('icon'), 'data/sprites/icons/fairies.png')

        local highlightBtn = dofile('data/scripts/ui/default_highlight_button.lua')
        highlightBtn.init(btnObj)

        local function choosePerk()
            perk.apply()
            game.audio.playSound('data/sounds/general/tile_super.json')
            if _object ~= nil then
                _object.destroy()
                _object = nil
            end
            if onComplete ~= nil then
                onComplete()
            end
        end
        btnObj.find('button').getComponent('button').onClick.subscribe(choosePerk)
    end
end

return cycleReward
