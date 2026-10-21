local buildCrafter = {}

local _object = nil
local _theme = require('data/scripts/ui/theme.lua')

local function _setStartingGold(targetGold)
    if game.control == nil then
        return
    end
    local current = game.control.getGold()
    if targetGold > current then
        game.control.gainGold(targetGold - current)
    elseif targetGold < current then
        game.control.loseGold(current - targetGold)
    end
end

local function _clearBackpack()
    if game.control == nil or game.control.tiles == nil then
        return
    end
    local count = game.control.tiles.getWidth() * game.control.tiles.getHeight()
    for i = 1, count do
        game.control.tiles.destroyTile(i)
    end
    game.audio.playSound('data/sounds/general/tile_destroy.json')
end

local function _setupItemButton(itemObject, itemData)
    local button = dofile('data/scripts/ui/default_highlighter.lua')
    button.init(itemObject)
    local tooltip = nil
    local function onMouseEnter()
        if tooltip ~= nil then
            tooltip.destroy()
        end
        tooltip = dofile('data/scripts/ui/tooltip.lua')
        tooltip.initInactive(itemData)
    end
    local function onMouseExit()
        if tooltip ~= nil then
            tooltip.destroy()
            tooltip = nil
        end
    end
    local clickTarget = itemObject.find('sprite').getComponent('button')
    clickTarget.onMouseEnter.subscribe(onMouseEnter)
    clickTarget.onMouseExit.subscribe(onMouseExit)

    local function onClick()
        if game.control ~= nil and game.control.tiles ~= nil then
            local success = game.control.tiles.setFirstOpenSlot(itemData)
            if success ~= false then
                game.audio.playSound('data/sounds/general/tile_place.json')
            else
                game.audio.playSound('data/sounds/general/fail.json')
            end
        end
    end
    clickTarget.onClick.subscribe(onClick)
end

function buildCrafter.init(onStartRun)
    local root = game.object.getRoot()
    local parent = root.find('main') or root
    _object = game.object.instantiate('data/scenes/build_crafter.json', parent)

    local data = require('data/scripts/data.lua')
    local content = _object.find('itemsScroll/viewport/content')
    
    -- Sort all items alphabetically
    local sorted = {}
    for _, tile in pairs(data.tiles) do
        if tile.key ~= nil and tile.icon ~= nil then
            table.insert(sorted, tile)
        end
    end
    table.sort(sorted, function(a, b)
        local na = game.text.getText(a.name) or a.key
        local nb = game.text.getText(b.name) or b.key
        return na < nb
    end)

    for i, itemData in ipairs(sorted) do
        local itemObj = game.object.instantiate('data/scenes/build_crafter_item.json', content)
        itemObj.name = 'item_' .. tostring(i)
        game.object.setVisual(itemObj.find('sprite'), itemData.icon)
        _theme.colorRarityImage(itemObj.find('outline/color').getComponent('image'), itemData.rarity)
        _setupItemButton(itemObj, itemData)
    end

    -- Gold buttons
    local function setupGoldBtn(name, amount)
        local btnObj = _object.find('goldBar/' .. name)
        local btnScript = dofile('data/scripts/ui/default_text_button.lua')
        btnScript.init(btnObj)
        btnObj.find('button').getComponent('button').onClick.subscribe(function()
            _setStartingGold(amount)
            game.audio.playSound('data/sounds/general/gold.json')
        end)
    end
    setupGoldBtn('gold10', 10)
    setupGoldBtn('gold1k', 1000)
    setupGoldBtn('gold50k', 50000)
    setupGoldBtn('goldMax', 999999)

    -- Clear button
    local clearBtn = _object.find('bottomBar/clearButton')
    local clearScript = dofile('data/scripts/ui/default_text_button.lua')
    clearScript.init(clearBtn)
    clearBtn.find('button').getComponent('button').onClick.subscribe(_clearBackpack)

    -- Start button
    local startBtn = _object.find('bottomBar/startButton')
    local startScript = dofile('data/scripts/ui/default_text_button.lua')
    startScript.init(startBtn)
    startBtn.find('button').getComponent('button').onClick.subscribe(function()
        if _object ~= nil then
            _object.destroy()
            _object = nil
        end
        game.audio.playSound('data/sounds/general/start_battle.json')
        if onStartRun ~= nil then
            onStartRun()
        end
    end)
end

function buildCrafter.destroy()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
end

return buildCrafter
