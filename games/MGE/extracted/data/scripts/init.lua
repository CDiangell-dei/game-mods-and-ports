local sceneControl = {}

local function _clear()
    engine.timer.setTimescale(1.0)
    engine.resetSandbox()

    engine.objectManager.getRoot().destroy()

    engine.debug.reset()
    engine.events.clear()
    engine.input.stopInput()
    engine.translator.clearTranslations()
    --engine.fileSystem.clear()
    engine.graphics.clearPostProcessors()
    engine.timer.clearQueuedActions()
    engine.timer.stopAllCoroutines()

    if config.isDevelopment then
        engine.dofile('data/scripts/fps.lua')
    end
end

local function _initializeSandbox(initialFade)
    local gameRoot = engine.objectManager.new()
    gameRoot.name = 'root'
    local function _getParent()
        return gameRoot
    end
    gameRoot.getParent = _getParent

    local crt = engine.sandbox.require('data/scripts/crt.lua')
    local fader = engine.sandbox.require('data/scripts/screen_fader.lua')
    local shader = engine.fileSystem.loadShader('data/crt.frag')
    shader:send('scale', 2.0)
    shader:send('strength', 1.0)
    shader:send('chromatic_aberration', 1.0)
    shader:send('noise', 0.011)
    shader:send('fade', 1.0)
    shader:send('time', 0.0)
    crt.init(shader)
    fader.init(shader, initialFade)
    engine.graphics.addPostProcess(shader)

    --Called after loading screen_fader to allow blocker/loading text to be above all
    local function _newObject(parent)
        parent = parent or gameRoot
        return engine.objectManager.new(parent)
    end

    local function _instantiateObject(prefab, parent)
        parent = parent or gameRoot
        return engine.objectManager.instantiate(prefab, parent)
    end

    local function _getRoot()
        return gameRoot
    end

    engine.sandbox.game.object.new = _newObject
    engine.sandbox.game.object.instantiate = _instantiateObject
    engine.sandbox.game.object.getRoot = _getRoot

    engine.sandbox.game.scene = {
        fadeToBlack = fader.fadeToBlack,
        fadeToWhite = fader.fadeToWhite,
        fadeIn = fader.fadeIn,
        enterTitle = sceneControl.enterTitle,
    }

    --data loading
    engine.translator.addTranslation('en_us', 'data/en_us.csv')
    engine.translator.addTranslation('en_us', 'data/pt_br_dialogue.csv')
    engine.translator.addTranslation('pt_br', 'data/pt_br.csv')
    engine.translator.addTranslation('pt_br', 'data/pt_br_dialogue.csv')
    engine.translator.setLanguage('pt_br')
    engine.sandbox.dofile('data/scripts/add_tiles.lua')
    engine.sandbox.dofile('data/scripts/add_buffs.lua')
    engine.sandbox.dofile('data/scripts/add_encounters.lua')
    -- MOD: carrega textos da tela de Mods e aplica os mods ativos (ver mods/README.md)
    engine.sandbox.dofile('mods/mod_boot.lua')
end

local function _instantiateTitle()
    local title = engine.dofile('data/scripts/title_control.lua')
    title.init(sceneControl.enterGame)
    engine.settings.save()
end

local _hasShownCredits = true

local function _instantiateTitleWithCredits()
    if _hasShownCredits then
        _instantiateTitle()
        return
    end
    _hasShownCredits = true
    local credits = engine.dofile('data/scripts/ui/credits_screen.lua')
    credits.init(_instantiateTitle)
end

local function _initializeGame()
    engine.graphics.addDefaultFont(12, 'data/fonts/12.ttf')
    engine.graphics.addDefaultFont(20, 'data/fonts/20.ttf')
    engine.graphics.addColorKey('accent', 'AC5369')
    engine.graphics.addColorKey('onpump', 'C57382')
    engine.graphics.addColorKey('always', '8C8CA1')
    engine.graphics.addColorKey('ondestroy', '8C8CA1')
    engine.graphics.addColorKey('enterbattle', 'BD7BA3')
    engine.graphics.addColorKey('winbattle', 'B67B78')
    engine.graphics.addColorKey('entershop', '97906E')
    engine.graphics.addColorKey('sell', '97906E')
    engine.graphics.addColorKey('purchase', '97906E')
    engine.graphics.addColorKey('reroll', '97906E')
    engine.graphics.addColorKey('losebattle', '7891B9')
    engine.graphics.addColorKey('enterencounter', '6A9D9E')
    engine.graphics.addColorKey('gainbuff', '8383B1')

    _clear()
    _initializeSandbox(0)
    local fader = engine.sandbox.require('data/scripts/screen_fader.lua')
    local function spawnTitle()
        _instantiateTitleWithCredits()
        fader.fadeIn(1.0, nil)
    end
    fader.fadeToBlack(0.1, spawnTitle)
end

function sceneControl.enterTitle()
    local fader = engine.sandbox.require('data/scripts/screen_fader.lua')
    local function enter()
        _clear()
        _initializeSandbox(1.0)
        _instantiateTitle()
        fader = engine.sandbox.require('data/scripts/screen_fader.lua')
        fader.fadeIn(1.0, engine.audio.stopAllSounds)

        

        --engine.dofile('data/scripts/fps.lua')
    end
    engine.audio.play('data/sounds/general/transition.json', nil, true)
    fader.fadeToWhite(0.5, enter)
end

function sceneControl.enterGame(mode)
    local fader = engine.sandbox.require('data/scripts/screen_fader.lua')
    local function enter()
        _clear()
        _initializeSandbox(-1.0)
        engine.settings.setSetting('gameMode', mode or 0)
        engine.sandbox.dofile('data/scripts/start.lua')
    end
    fader.fadeToBlack(0.5, enter)
end

local splash = engine.dofile('data/scripts/splash.lua')
splash.init(_initializeGame)
