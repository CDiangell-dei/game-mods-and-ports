config = {
    canvasWidth = 675,
    canvasHeight = 540,
    settings = {
        --SOUND
		overallVolume = 50,
		effectVolume = 100,
		musicVolume = 50,
		playSoundInBackground = 1,
        disableDialogueSounds = 0,

        --GRAPHICS
        display = 1,
		resolution = 1,
		vsync = 1,
        language = 1,
        gameMode = 0,
        autoBattle = 0,
        fullscreen = 0,
		crtStrength = 100,
		chromaticAberration = 1,
		filmGrain = 0,

        --GAMEPLAY
        skipAlreadySeen = 0,
	},
    defaultFont = 'data/fonts/12.ttf',
    defaultFontSize = 12,
}

function love.conf(t)
    t.identity = 'monster_girl_encounters'
    t.window.title = 'Monster Girl Encounters'
    t.window.width = 675
    t.window.height = 540
    t.window.fullscreen = false
    if love.system and love.system.getOS and (love.system.getOS() == 'Android' or love.system.getOS() == 'iOS') then
        t.window.fullscreen = true
        t.window.width = 0
        t.window.height = 0
    end
    t.window.vsync = config.settings.vsync
    t.modules.physics = false
    t.modules.thread = false
    t.modules.video = false
end
