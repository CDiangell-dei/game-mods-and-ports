local map = {}

local _map
local _icons = {
    default = 'data/sprites/ui/map_entrance.png',
    unknown = 'data/sprites/ui/map_random.png',
    randomEncounter = 'data/sprites/ui/map_random.png',
    elite = 'data/sprites/ui/map_elite.png',
    battle = 'data/sprites/ui/map_battle.png',
    shop = 'data/sprites/ui/map_shop.png',
    boss = 'data/sprites/ui/map_boss.png',
}

local function _selectLeft()
    game.control.selectEncounterBranch(true)
end

local function _selectRight()
    game.control.selectEncounterBranch(false)
end

local function _maskAndDestroy(onComplete)
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

local function _setIcon(object, type)
    game.object.setVisual(object, _icons[type])
    local tooltip = nil
    local function showTooltip()
        if tooltip ~= nil then
            tooltip.destroy()
        end
        tooltip = dofile('data/scripts/ui/tooltip_simple.lua')
        tooltip.init('map_' .. type, 127)
    end
    local function destroyTooltip()
        if tooltip ~= nil then
            tooltip.destroy()
            tooltip = nil
        end
    end
    object.getComponent('button').onMouseEnter.subscribe(showTooltip)
    object.getComponent('button').onMouseExit.subscribe(destroyTooltip)
end

function map.openMap(encounterTree)
    local ditherer = dofile('data/scripts/ui/staggered_dither.lua')
    _map = game.object.instantiate('data/scenes/map.json', game.object.getRoot().find('main'))
    --current
    if encounterTree.type == nil then
        _setIcon(_map.find('container/current/sprite'), 'default')
    else
        _setIcon(_map.find('container/current/sprite'), encounterTree.type)
    end
    ditherer.queueDitherIn(_map.find('container/current').getComponent('mask'), 0)

    _setIcon(_map.find('container/left/button'), encounterTree.left.type)
    ditherer.queueDitherIn(_map.find('container/left').getComponent('mask'), 1)
    _setIcon(_map.find('container/leftLeft/sprite'), encounterTree.left.left.type)
    ditherer.queueDitherIn(_map.find('container/leftLeft').getComponent('mask'), 2)
    _setIcon(_map.find('container/leftRight/sprite'), encounterTree.left.right.type)
    ditherer.queueDitherIn(_map.find('container/leftRight').getComponent('mask'), 2)
    _setIcon(_map.find('container/right/button'), encounterTree.right.type)
    ditherer.queueDitherIn(_map.find('container/right').getComponent('mask'), 1)
    _setIcon(_map.find('container/rightLeft/sprite'), encounterTree.right.left.type)
    ditherer.queueDitherIn(_map.find('container/rightLeft').getComponent('mask'), 2)
    _setIcon(_map.find('container/rightRight/sprite'), encounterTree.right.right.type)
    ditherer.queueDitherIn(_map.find('container/rightRight').getComponent('mask'), 2)

    game.object.setVisual(_map.find('container/left/outline/shape'), _icons[encounterTree.left.type])
    local leftButton = dofile('data/scripts/ui/default_button.lua')
    leftButton.init(_map.find('container/left'))
    local function selectLeft()
        _maskAndDestroy(_selectLeft)
    end
    _map.find('container/left/button').getComponent('button').onClick.subscribe(selectLeft)

    game.object.setVisual(_map.find('container/right/outline/shape'), _icons[encounterTree.right.type])
    local rightButton = dofile('data/scripts/ui/default_button.lua')
    rightButton.init(_map.find('container/right'))
    local function selectRight()
        _maskAndDestroy(_selectRight)
    end
    _map.find('container/right/button').getComponent('button').onClick.subscribe(selectRight)

    ditherer.executeDither()
end

return map
