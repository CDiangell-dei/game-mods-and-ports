local titleControl = {}

local function _openCollection()
    engine.sandbox.dofile('data/scripts/ui/collection.lua')
end

local function _openSettings()
    engine.sandbox.dofile('data/scripts/ui/settings.lua')
end

-- MOD: abre a tela de Mods (mods/ui/mods_screen.lua)
local function _openMods()
    engine.sandbox.dofile('mods/ui/mods_screen.lua')
end

local function _openTwitter()
    engine.system.openUri('https://x.com/reine_soft')
end

local function _stagger(stagger, graphic, level)
    stagger.queueDitherIn(graphic, level)
    return level + 1
end

local function _staggerUI(object)
    local stagger = engine.sandbox.dofile('data/scripts/ui/staggered_dither.lua')
    stagger.transitionTime = 0.5
    local level = 1
    local logo = object.find('logo').getComponent('mask')
    level = _stagger(stagger, logo, level)
    
    local story = object.find('buttons/story').getComponent('mask')
    level = _stagger(stagger, story, level)
    
    local endless = object.find('buttons/endless').getComponent('mask')
    level = _stagger(stagger, endless, level)

    local collection = object.find('buttons/collection').getComponent('mask')
    level = _stagger(stagger, collection, level)

    local settings = object.find('buttons/settings').getComponent('mask')
    level = _stagger(stagger, settings, level)

    local mods = object.find('buttons/mods').getComponent('mask')
    level = _stagger(stagger, mods, level)

    if love.system.getOS() ~= 'Web' then
        local quit = object.find('buttons/quit').getComponent('mask')
        level = _stagger(stagger, quit, level)
    end
    
    local social = object.find('socialButton').getComponent('mask')
    level = _stagger(stagger, social, level)
    local sylph = object.find('sylph').getComponent('mask')
    level = _stagger(stagger, sylph, level)
    stagger.executeDither(nil)
end

function titleControl.init(enterGame)
    local root = engine.objectManager.getRoot().find('root')
    local object = engine.objectManager.instantiate('data/scenes/title.json', root)

    local storyButton = object.find('buttons/story/button').getComponent('button')
    storyButton.onClick.subscribe(function() enterGame(0) end)
    local storyButtonScript = engine.sandbox.dofile('data/scripts/ui/default_text_button.lua')
    storyButtonScript.init(object.find('buttons/story'))

    local endlessButton = object.find('buttons/endless/button').getComponent('button')
    endlessButton.onClick.subscribe(function() enterGame(1) end)
    local endlessButtonScript = engine.sandbox.dofile('data/scripts/ui/default_text_button.lua')
    endlessButtonScript.init(object.find('buttons/endless'))

    local collectionButton = object.find('buttons/collection/button').getComponent('button')
    collectionButton.onClick.subscribe(_openCollection)
    local collectionButtonScript = engine.sandbox.dofile('data/scripts/ui/default_text_button.lua')
    collectionButtonScript.init(object.find('buttons/collection'))

    local settingsButton = object.find('buttons/settings/button').getComponent('button')
    settingsButton.onClick.subscribe(_openSettings)
    local settingsButtonScript = engine.sandbox.dofile('data/scripts/ui/default_text_button.lua')
    settingsButtonScript.init(object.find('buttons/settings'))

    -- MOD: botao Mods perfeitamente integrado à lista principal
    local modsButton = object.find('buttons/mods/button').getComponent('button')
    modsButton.onClick.subscribe(_openMods)
    local modsButtonScript = engine.sandbox.dofile('data/scripts/ui/default_text_button.lua')
    modsButtonScript.init(object.find('buttons/mods'))

    if love.system.getOS() == 'Web' then
        local quitButton = object.find('buttons/quit')
        quitButton.destroy()
    else
        local quitButton = object.find('buttons/quit/button').getComponent('button')
        quitButton.onClick.subscribe(engine.system.quit)
        local quitButtonScript = engine.sandbox.dofile('data/scripts/ui/default_text_button.lua')
        quitButtonScript.init(object.find('buttons/quit'))
    end
    
    local twitter = object.find('socialButton')
    local twitterSprite = object.find('socialButton/sprite')
    local tooltip = nil
    local function spawnTooltip()
        if tooltip ~= nil then
            tooltip.destroy()
        end
        tooltip = engine.sandbox.dofile('data/scripts/ui/tooltip_simple.lua')
        tooltip.init('socials_tooltip')
        engine.objectManager.setVisual(twitterSprite, 'data/sprites/ui/twitter_empty.png')
        twitter.setSize(40, 40)
        twitterSprite.setSize(40, 40)
    end
    local function destroyTooltip()
        if tooltip ~= nil then
            tooltip.destroy()
        end
        tooltip = nil
        engine.objectManager.setVisual(twitterSprite, 'data/sprites/ui/twitter.png')
        twitter.setSize(36, 36)
        twitterSprite.setSize(36, 36)
    end
    local twitterButton = object.find('socialButton/sprite').getComponent('button')
    twitterButton.onClick.subscribe(_openTwitter)
    twitterButton.onMouseEnter.subscribe(spawnTooltip)
    twitterButton.onMouseExit.subscribe(destroyTooltip)

    engine.music.play('data/sounds/ambient1.json')
    local function stagger()
        _staggerUI(object)
    end
    engine.timer.queue(1.0, stagger)
end

return titleControl
