local selector = {
    modes = {},
    itemMaxCount = 3,
}

local _ui = dofile('data/scripts/ui/initial_selector.lua')
local _mods = require('mods/mod_manager.lua') -- MOD
local _runSave = require('data/scripts/run_save.lua') -- MOD (save/continue)
local _saved = nil -- MOD (save/continue): the run found on disk, if any
local _seed = nil
local _selectedMode = 1
local _selectedItems = {}
local _possibleItems = {
    'canteen',
    'sandwich',
    'binding_ropes',
    'bloodgem',
    'dandelion_bouquet',
    'lucky_clover',
}
local _onComplete = nil

local function _addItems()
    local data = require('data/scripts/data.lua')
    for _, key in ipairs(_possibleItems) do
        local item = data.tiles[key]
        _ui.addItem(item)
    end
end

function selector.enterModeSelection()
    _ui.enterModeSelection()
    for _, v in ipairs(selector.modes) do
        _ui.addItem(v)
    end
    _ui.fadeIn()
end

function selector.enterItemSelection()
    if _seed ~= nil then
        math.randomseed(_seed)
    end
    _ui.enterItemSelection()
    _addItems()
    _ui.fadeIn()
end

function selector.returnToTitle()
    game.scene.enterTitle()
end

function selector.enterGame()
    local modeInfo = selector.modes[_selectedMode] or selector.modes[1]
    local function complete()
        _ui.destroy()
        _runSave.clear() -- MOD (save/continue): a new run replaces any saved one
        game.control = require('data/scripts/game_control.lua')
		game.control.setSeed(_seed)
        if modeInfo.startGame ~= nil then
            modeInfo.startGame()
        end
        if modeInfo.isSandbox then
            -- Pass a dummy callback so the intro fader doesn't launch completeEncounter/map!
            game.control.init(function() end)
            require('data/scripts/stat_tracker.lua')
            for _, v in pairs(_selectedItems) do
                game.control.tiles.setFirstOpenSlot(v)
            end
            _mods.call('onRunStarted', game.control)

            -- Open Build Crafter cleanly in main
            local crafter = dofile('data/scripts/ui/build_crafter.lua')
            crafter.init(function()
                game.control.completeEncounter()
            end)
        else
            game.control.init(game.control.completeEncounter)
            require('data/scripts/stat_tracker.lua')
            for _, v in pairs(_selectedItems) do
                game.control.tiles.setFirstOpenSlot(v)
            end
            _mods.call('onRunStarted', game.control)
        end

        if _onComplete then
            _onComplete()
        end
    end
    game.audio.playSound('data/sounds/general/transition.json')
    game.scene.fadeToBlack(0.5, complete)
end

function selector.init(onComplete)
    _onComplete = onComplete
    _ui.instantiate(selector)
    if _seed == nil then
        _seed = os.time()
        math.randomseed(_seed)
    end

    local isEndless = game.data.getSetting('gameMode') > 0.5
    if isEndless then
        selector.modes = {
            {
                name = 'endless_classic_name',
                description = 'endless_classic_desc',
                icon = 'data/sprites/icons/fairies.png',
                isSandbox = false,
                startGame = function()
                    game.data.setSetting('gameMode', 1)
                    game.control.gainGold(10)
                end,
            },
            {
                name = 'endless_sandbox_name',
                description = 'endless_sandbox_desc',
                icon = 'data/sprites/icons/sphinx.png',
                isSandbox = true,
                startGame = function()
                    game.data.setSetting('gameMode', 1)
                    game.control.gainGold(10)
                end,
            },
        }
    else
        selector.modes = {
            {
                name = 'story_mode_button',
                description = 'standard_mode_description',
                icon = 'data/sprites/icons/fairies.png',
                isSandbox = false,
                startGame = function()
                    game.data.setSetting('gameMode', 0)
                    game.control.gainGold(10)
                end,
            },
        }
    end

    _saved = _runSave.load()
    if _saved ~= nil then
        local saveMode = _saved.gameMode or 0
        local currentMode = isEndless and 1 or 0
        if saveMode == currentMode then
            selector.enterRunChoice()
        else
            selector.beginNewRun()
        end
    else
        selector.beginNewRun()
    end
    local function startMusic()
        game.audio.playMusic('data/sounds/ambient1.json')
    end
    game.scene.fadeIn(0.5, startMusic)
end

function selector.beginNewRun()
    local isEndless = game.data.getSetting('gameMode') > 0.5
    if isEndless then
        selector.enterModeSelection()
    else
        selector.enterItemSelection()
    end
end

function selector.enterRunChoice()
    _ui.enterRunChoice()
    local missing = _runSave.getMissingMods(_saved)
    local description = game.text.getText('run_floor_label') .. ' ' .. tostring(_saved.run.floor)
    local isLocked = false
    if #missing > 0 then
        description = game.text.getText('run_mods_missing') .. ' ' .. table.concat(missing, ', ')
        isLocked = true
    end
    _ui.addItem({
        name = 'continue_run',
        description = description,
        icon = 'data/sprites/icons/continue.png',
        locked = isLocked,
    })
    _ui.addItem({
        name = 'new_run',
        description = 'new_run_description',
        icon = 'data/sprites/icons/goblin.png',
    })
    _ui.fadeIn()
end

function selector.confirmRunChoice(index)
    if index == 1 then
        selector.continueRun()
    else
        selector.beginNewRun()
    end
end

function selector.continueRun()
    local state = _saved
    local function complete()
        _ui.destroy()
        game.control = require('data/scripts/game_control.lua')
        _runSave.restoreBeforeInit(state)
        game.control.init()
        require('data/scripts/stat_tracker.lua')
        _runSave.restoreAfterInit(state)
        if _onComplete then
            _onComplete()
        end
    end
    game.audio.playSound('data/sounds/general/transition.json')
    game.scene.fadeToBlack(0.5, complete)
end

function selector.setMode(index)
    _selectedMode = index
end

function selector.setItems(items)
    _selectedItems = items
end

function selector.setSeed(seed)
    _seed = seed
end

return selector
