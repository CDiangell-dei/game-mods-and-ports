local _activePanel = nil
local _tilesButton = dofile('data/scripts/ui/default_text_button.lua')
local _encountersButton = dofile('data/scripts/ui/default_text_button.lua')
local _object = game.object.instantiate('data/scenes/collection.json')

local function _destroyActive()
    if _activePanel ~= nil then
        _activePanel.destroy()
        _activePanel = nil
    end
end

local function _close()
    _destroyActive()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
    game.collectionOpen = false
end


local function _spawnTiles()
    _destroyActive()
    _activePanel = dofile('data/scripts/ui/collection_items.lua')
    _tilesButton.select()
    _encountersButton.deselect()
end

local function _spawnEncounters()
    _destroyActive()
    _activePanel = dofile('data/scripts/ui/bestiary.lua')
    _tilesButton.deselect()
    _encountersButton.select()
end

local function _init()
    game.collectionOpen = true
    local closeButtonObject = _object.find('closeButton')
    local closeButton = dofile('data/scripts/ui/default_button.lua')
    closeButton.init(closeButtonObject)
    closeButtonObject.find('button').getComponent('button').onClick.subscribe(_close)

    local tilesButtonObject = _object.find('tilesButton')
    _tilesButton.init(tilesButtonObject)
    tilesButtonObject.find('button').getComponent('button').onClick.subscribe(_spawnTiles)

    local encountersButtonObject = _object.find('encountersButton')
    _encountersButton.init(encountersButtonObject)
    encountersButtonObject.find('button').getComponent('button').onClick.subscribe(_spawnEncounters)

    local fader = dofile('data/scripts/ui/dither_fader.lua')
    fader.init(_object.getComponent('mask'), 0, true)
    fader.fadeTo(100, 0.2, nil)
    _spawnTiles()
end

_init()