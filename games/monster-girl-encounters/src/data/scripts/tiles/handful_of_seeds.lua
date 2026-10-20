local handfulOfSeeds = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

local _temporaryItems = {}

local function _clearItems()
    for _, tile in ipairs(_temporaryItems) do
        local index = tile.index
        game.control.tiles.destroyTile(index, true)
    end
    _temporaryItems = {}
end

local function _spawnTemporaryItems()
    local roller = dofile('data/scripts/encounters/shop_roller.lua')
    local modifiers = {
        requiredRarity = {
            1
        },
        excludedSpecific = {
            'spacious_bag',
        },
    }
    local width = game.control.tiles.getWidth()
    for x=1, width do
        local index = game.control.tiles.getIndex(x, 1)
        local data = roller.getRandomItem(modifiers)
        game.control.tiles.setTile(index, data)
        local tile = game.control.tiles.getTile(index)
        tile._conjured = true
        table.insert(_temporaryItems, tile)
    end
end

local function _trySpawnItems()
    local width = game.control.tiles.getWidth()
    for x=1, width do
        local index = game.control.tiles.getIndex(x, 1)
        local tile = game.control.tiles.getTile(index)
        if tile ~= nil then
            return
        end
    end
    game.control.ui.triggerTile(handfulOfSeeds.index, true)
    _spawnTemporaryItems()
end

function handfulOfSeeds.getVar(_)
    return nil
end

function handfulOfSeeds.onDestroy()
    _clearItems()
end

function handfulOfSeeds.onEnterEncounter(encounterType)
    if encounterType == 'battle' or encounterType == 'boss' or encounterType == 'elite' then
        _trySpawnItems()
    end
end

function handfulOfSeeds.onExitEncounter()
    _clearItems()
end

return handfulOfSeeds
