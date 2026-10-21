local map = {}

local _mods = require('mods/mod_manager.lua') -- MOD
local _map
local _activeTooltip = nil
local _icons = {
    default = 'data/sprites/ui/map_entrance.png',
    unknown = 'data/sprites/ui/map_random.png',
    randomEncounter = 'data/sprites/ui/map_random.png',
    elite = 'data/sprites/ui/map_elite.png',
    battle = 'data/sprites/ui/map_battle.png',
    shop = 'data/sprites/ui/map_shop.png',
    boss = 'data/sprites/ui/map_boss.png',
}

local function _clearTooltip()
    if _activeTooltip ~= nil then
        _activeTooltip.destroy()
        _activeTooltip = nil
    end
end

local function _selectLeft()
    _clearTooltip()
    game.control.selectEncounterBranch(true)
end

local function _selectRight()
    _clearTooltip()
    game.control.selectEncounterBranch(false)
end

local function _maskAndDestroy(onComplete)
    _clearTooltip()
    local function completeFade()
        if _map ~= nil then
            _map.destroy()
            _map = nil
        end
        onComplete()
    end
    local fader = dofile('data/scripts/ui/dither_fader.lua')
    fader.init(_map.getComponent('mask'), 100, false)
    fader.fadeTo(0, 0.2, completeFade)
end

local function _getTooltipText(type, encounter)
    local typeKey = 'map_' .. (type or 'battle')
    local typeLabel = game.text.getText(typeKey) or type
    if encounter ~= nil and encounter.name ~= nil then
        local enemyName = game.text.getText(encounter.name)
        if enemyName ~= nil and enemyName ~= '' and enemyName ~= encounter.name then
            if type == 'battle' or type == 'elite' or type == 'boss' then
                return enemyName .. '\n(' .. typeLabel .. ')'
            else
                return enemyName
            end
        end
    end
    return typeLabel
end

local function _setIcon(object, type, encounter)
    local isPreview = _mods.filter('isEnemyPreviewActive', false)
    local visual = _icons[type] or _icons.default
    if isPreview and encounter ~= nil and encounter.icon ~= nil then
        visual = encounter.icon
    end
    game.object.setVisual(object, visual)

    local function showTooltip()
        _clearTooltip()
        _activeTooltip = dofile('data/scripts/ui/tooltip_simple.lua')
        local text = isPreview and _getTooltipText(type, encounter) or game.text.getText('map_' .. (type or 'battle'))
        _activeTooltip.init(text, 140)
    end
    local function destroyTooltip()
        _clearTooltip()
    end
    local btn = object.getComponent('button')
    if btn ~= nil then
        btn.onMouseEnter.subscribe(showTooltip)
        btn.onMouseExit.subscribe(destroyTooltip)
    end
end

function map.openMap(encounterTree)
    local ditherer = dofile('data/scripts/ui/staggered_dither.lua')
    _map = game.object.instantiate('data/scenes/map.json', game.object.getRoot().find('main'))

    -- current
    if encounterTree.type == nil then
        _setIcon(_map.find('container/current/sprite'), 'default', encounterTree.encounter)
    else
        _setIcon(_map.find('container/current/sprite'), encounterTree.type, encounterTree.encounter)
    end
    ditherer.queueDitherIn(_map.find('container/current').getComponent('mask'), 0)

    -- upcoming branches
    _setIcon(_map.find('container/left/button'), encounterTree.left.type, encounterTree.left.encounter)
    ditherer.queueDitherIn(_map.find('container/left').getComponent('mask'), 1)

    _setIcon(_map.find('container/leftLeft/sprite'), encounterTree.left.left.type, encounterTree.left.left.encounter)
    ditherer.queueDitherIn(_map.find('container/leftLeft').getComponent('mask'), 2)

    _setIcon(_map.find('container/leftRight/sprite'), encounterTree.left.right.type, encounterTree.left.right.encounter)
    ditherer.queueDitherIn(_map.find('container/leftRight').getComponent('mask'), 2)

    _setIcon(_map.find('container/right/button'), encounterTree.right.type, encounterTree.right.encounter)
    ditherer.queueDitherIn(_map.find('container/right').getComponent('mask'), 1)

    _setIcon(_map.find('container/rightLeft/sprite'), encounterTree.right.left.type, encounterTree.right.left.encounter)
    ditherer.queueDitherIn(_map.find('container/rightLeft').getComponent('mask'), 2)

    _setIcon(_map.find('container/rightRight/sprite'), encounterTree.right.right.type, encounterTree.right.right.encounter)
    ditherer.queueDitherIn(_map.find('container/rightRight').getComponent('mask'), 2)

    -- left button outline & click
    game.object.setVisual(_map.find('container/left/outline/shape'), _icons[encounterTree.left.type] or _icons.battle)
    local leftButton = dofile('data/scripts/ui/default_button.lua')
    leftButton.init(_map.find('container/left'))
    local function selectLeft()
        _maskAndDestroy(_selectLeft)
    end
    _map.find('container/left/button').getComponent('button').onClick.subscribe(selectLeft)

    -- right button outline & click
    game.object.setVisual(_map.find('container/right/outline/shape'), _icons[encounterTree.right.type] or _icons.battle)
    local rightButton = dofile('data/scripts/ui/default_button.lua')
    rightButton.init(_map.find('container/right'))
    local function selectRight()
        _maskAndDestroy(_selectRight)
    end
    _map.find('container/right/button').getComponent('button').onClick.subscribe(selectRight)

    ditherer.executeDither()
end

return map
