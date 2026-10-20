local pauseMenu = {}

local _object = game.object.instantiate('data/scenes/menu.json')

local function _close()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
    game.timer.setTimescale(1.0)
end

local function _openCollection()
    dofile('data/scripts/ui/collection.lua')
end

local function _openSettings()
    dofile('data/scripts/ui/settings.lua')
    game.object.getRoot().find('settings/blocker').getComponent('image').setColor(0, 0, 0, 0)
end

local function _enterTitle()
    game.audio.stopMusic()
    game.scene.enterTitle()
end

local function _copySeed()
    if love.system.setClipboardText ~= nil and game.control ~= nil then
        love.system.setClipboardText(tostring(game.control.getSeed()))
    end
end

local function _init()
    local ditherer = dofile('data/scripts/ui/staggered_dither.lua')
    game.timer.setTimescale(0)

    local resumeButtonObject = _object.find('buttons/resumeButton')
    local resumeButton = dofile('data/scripts/ui/default_text_button.lua')
    resumeButton.init(resumeButtonObject)
    resumeButtonObject.find('button').getComponent('button').onClick.subscribe(_close)

    local collectionButtonObject = _object.find('buttons/collectionButton')
    local collectionButton = dofile('data/scripts/ui/default_text_button.lua')
    collectionButton.init(collectionButtonObject)
    collectionButtonObject.find('button').getComponent('button').onClick.subscribe(_openCollection)

    local settingsButtonObject = _object.find('buttons/settingsButton')
    local settingsButton = dofile('data/scripts/ui/default_text_button.lua')
    settingsButton.init(settingsButtonObject)
    settingsButtonObject.find('button').getComponent('button').onClick.subscribe(_openSettings)

    local returnButtonObject = _object.find('buttons/returnToTitleButton')
    local returnButton = dofile('data/scripts/ui/default_text_button.lua')
    returnButton.init(returnButtonObject)
    returnButtonObject.find('button').getComponent('button').onClick.subscribe(_enterTitle)

    local seedText = _object.find('seedPanel/seedLabel').getComponent('text')
    local seedLabel = game.text.getText('seed_label')
    seedText.setText(seedLabel .. ': ' .. tostring(game.control.getSeed()))
    local copySeedButtonObject = _object.find('seedPanel/copySeedButton')
    local copySeedButton = dofile('data/scripts/ui/default_text_button.lua')
    copySeedButton.init(copySeedButtonObject)
    copySeedButtonObject.find('button').getComponent('button').onClick.subscribe(_copySeed)

    ditherer.queueDitherIn(_object.getComponent('mask'), 0)
    ditherer.queueDitherIn(resumeButtonObject.getComponent('mask'), 1)
    ditherer.queueDitherIn(collectionButtonObject.getComponent('mask'), 2)
    ditherer.queueDitherIn(settingsButtonObject.getComponent('mask'), 3)
    ditherer.queueDitherIn(returnButtonObject.getComponent('mask'), 4)
    ditherer.queueDitherIn(copySeedButtonObject.getComponent('mask'), 6)
    ditherer.executeDither()
end

_init()

return pauseMenu
