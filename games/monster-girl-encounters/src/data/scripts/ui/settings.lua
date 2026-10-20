local settings = {}

local _baseObject = game.object.instantiate('data/scenes/settings.json')
local _object = _baseObject.find('background')
local _ditherer = dofile('data/scripts/ui/staggered_dither.lua')
local _closeButton

local function _spawnLabel(title, textKey, index)
    local parent = _object.find('scroll/viewport/content')
    local label = game.object.instantiate('data/scenes/settings_label.json', parent)
    label.name = title
    label.find('shadow').getComponent('text').setText(textKey)
    label.find('text').getComponent('text').setText(textKey)
    _ditherer.queueDitherIn(label.getComponent('mask'), index)
end

local function _spawnSlider(settingKey, labelKey, index)
    local parent = _object.find('scroll/viewport/content')
    local slider = game.object.instantiate('data/scenes/settings_slider.json', parent)
    slider.name = settingKey
    slider.find('label/shadow').getComponent('text').setText(labelKey)
    slider.find('label/text').getComponent('text').setText(labelKey)

    local function change(value)
        game.data.setSetting(settingKey, value)
    end
    local value = game.data.getSetting(settingKey)
    slider.find('slider').getComponent('slider').setValue(value)
    slider.find('slider').getComponent('slider').onValueChange.subscribe(change)

    local button = dofile('data/scripts/ui/default_slider.lua')
    button.init(slider.find('slider'), slider.find('label/text').getComponent('text'))
    _ditherer.queueDitherIn(slider.getComponent('mask'), index)
end

local function _spawnToggle(settingKey, labelKey, index)
    local parent = _object.find('scroll/viewport/content')
    local toggle = game.object.instantiate('data/scenes/settings_toggle.json', parent)
    toggle.name = settingKey
    toggle.find('label/shadow').getComponent('text').setText(labelKey)
    toggle.find('label/text').getComponent('text').setText(labelKey)
    local function change(isOn)
        if isOn then
            game.data.setSetting(settingKey, 1)
        else
            game.data.setSetting(settingKey, 0)
        end
        if settingKey == 'language' then
            if isOn then
                game.text.setLanguage('pt_br')
            else
                game.text.setLanguage('en_us')
            end
        end
    end
    local saveValue = game.data.getSetting(settingKey)
    local button = dofile('data/scripts/ui/default_toggle.lua')
    button.init(toggle.find('toggle'), toggle.find('label/text').getComponent('text'))
    button.setIsOn(saveValue > 0.5)
    button.onToggle.subscribe(change)
    _ditherer.queueDitherIn(toggle.getComponent('mask'), index)
end

local function _spawnLanguage(index)
    local parent = _object.find('scroll/viewport/content')
    local language = game.object.instantiate('data/scenes/settings_language.json', parent)
    language.name = 'language'

    local english = dofile('data/scripts/ui/default_toggle.lua')
    local portuguese = dofile('data/scripts/ui/default_toggle.lua')
    english.init(language.find('english/toggle'), language.find('english/label').getComponent('text'))
    portuguese.init(language.find('portuguese/toggle'), language.find('portuguese/label').getComponent('text'))

    local isChanging = false
    local function select(languageCode, selected, other, isOn)
        if isChanging then
            return
        end
        if not isOn then
            selected.setIsOn(true)
            return
        end
        isChanging = true
        other.setIsOn(false)
        game.data.setSetting('language', languageCode == 'pt_br' and 1 or 0)
        game.text.setLanguage(languageCode)
        isChanging = false
    end

    if game.data.getSetting('language') > 0.5 then
        portuguese.setIsOn(true)
        english.setIsOn(false)
    else
        english.setIsOn(true)
        portuguese.setIsOn(false)
    end
    english.onToggle.subscribe(function(isOn)
        select('en_us', english, portuguese, isOn)
    end)
    portuguese.onToggle.subscribe(function(isOn)
        select('pt_br', portuguese, english, isOn)
    end)
    _ditherer.queueDitherIn(language.getComponent('mask'), index)
end

local function _close()
    if _baseObject ~= nil then
        _baseObject.destroy()
        _baseObject = nil
        _object = nil
    end
    game.data.save()
end

local function _activateInitialResolution(toggle1, toggle2, toggle3, toggle4, toggleFull)
    toggle1.setIsOn(false)
    toggle2.setIsOn(false)
    toggle3.setIsOn(false)
    toggle4.setIsOn(false)
    if toggleFull ~= nil then
        toggleFull.setIsOn(false)
    end
    local currentResolution = game.data.getSetting('resolution')
    local isFullscreen = game.data.getSetting('fullscreen') > 0.5 or currentResolution == 0
    local activeToggle
    if isFullscreen and toggleFull ~= nil then
        toggleFull.setIsOn(true)
        activeToggle = toggleFull
    elseif currentResolution == 1 then
        toggle1.setIsOn(true)
        activeToggle = toggle1
    elseif currentResolution == 2 then
        toggle2.setIsOn(true)
        activeToggle = toggle2
    elseif currentResolution == 3 then
        toggle3.setIsOn(true)
        activeToggle = toggle3
    elseif currentResolution == 4 then
        toggle4.setIsOn(true)
        activeToggle = toggle4
    elseif toggleFull ~= nil then
        toggleFull.setIsOn(true)
        activeToggle = toggleFull
    else
        toggle1.setIsOn(true)
        activeToggle = toggle1
        currentResolution = 1
    end
    return activeToggle, currentResolution
end

local function _highlightResolution()
    _object.find('scroll/viewport/content/resolution/label/text').getComponent('text').
        setColor(0.427451, 0.427451, 0.5294118, 1.0)
end

local function _unhighlightResolution()
    _object.find('scroll/viewport/content/resolution/label/text').getComponent('text').
        setColor(0.33333331, 0.3333333, 0.4431373, 1.0)
end

local function _spawnResolutionConfirmation(onConfirm, onRevert)
    local confirmation = game.object.instantiate('data/scenes/settings_confirmation.json', _object)

    local translatedRevert = game.text.getText('revert_button')
    local time = 11
    local increment = 11
    local revert

    local function update()
        local deltaTime = game.timer.getUnscaledDeltaTime()
        time = time - deltaTime
        if time <= 0 then
            confirmation.destroy()
            game.events.unsubscribe('update', update)
            onRevert()

            _closeButton.onClick.unsubscribe(revert)
            _closeButton.onClick.subscribe(_close)
            return
        end
        local flooredTime = math.floor(time)
        if flooredTime < increment then
            local label
            if flooredTime < 10 then
                label = '[0'
            else
                label = '['
            end
            label = label .. tostring(flooredTime) .. '] ' .. translatedRevert
            confirmation.find('revertButton/label/shadow').getComponent('text').setText(label)
            confirmation.find('revertButton/label/text').getComponent('text').setText(label)
            increment = flooredTime
        end
    end

    local revertButton = dofile('data/scripts/ui/default_text_button.lua')
    revertButton.init(confirmation.find('revertButton'))
    revert = function()
        confirmation.destroy()
        game.events.unsubscribe('update', update)
        onRevert()

        _closeButton.onClick.unsubscribe(revert)
        _closeButton.onClick.subscribe(_close)
    end
    confirmation.find('revertButton/button').getComponent('button').onClick.subscribe(revert)

    local confirmButton = dofile('data/scripts/ui/default_text_button.lua')
    confirmButton.init(confirmation.find('confirmButton'))
    local function confirm()
        confirmation.destroy()
        game.events.unsubscribe('update', update)
        onConfirm()

        _closeButton.onClick.unsubscribe(revert)
        _closeButton.onClick.subscribe(_close)
    end
    confirmation.find('confirmButton/button').getComponent('button').onClick.subscribe(confirm)

    _closeButton.onClick.unsubscribe(_close)
    _closeButton.onClick.subscribe(revert)
    game.events.subscribe('update', update)
end

local function _spawnResolution(index)
    local parent = _object.find('scroll/viewport/content')
    local resolution = game.object.instantiate('data/scenes/settings_resolution.json', parent)
    local settingKey = 'resolution'
    local activeToggle
    local activeValue = 0
    local isToggling = false

    local function press(toggleObject, value)
        if isToggling then
            return
        end
        isToggling = true
        if toggleObject == activeToggle then
            toggleObject.setIsOn(true)
            isToggling = false
            return
        end
        local function onConfirm()
            activeToggle.setIsOn(false)
            activeToggle = toggleObject
            activeToggle.setIsOn(true)
            activeValue = value
            isToggling = false
        end

        local previousResolution = game.data.getSetting('resolution')
        local previousFullscreen = game.data.getSetting('fullscreen')
        local function onRevert()
            toggleObject.setIsOn(false)
            activeToggle.setIsOn(true)
            game.data.setSetting('resolution', previousResolution)
            game.data.setSetting('fullscreen', previousFullscreen)
            isToggling = false
        end
        if value == 0 then
            game.data.setSetting('fullscreen', 1)
        else
            game.data.setSetting('resolution', value)
            game.data.setSetting('fullscreen', 0)
        end
        _spawnResolutionConfirmation(onConfirm, onRevert)
    end

    local toggle1 = dofile('data/scripts/ui/default_toggle.lua')
    toggle1.init(resolution.find('toggle1'), nil)
    local function onToggle1(_)
        press(toggle1, 1)
    end

    local toggle2 = dofile('data/scripts/ui/default_toggle.lua')
    toggle2.init(resolution.find('toggle2'), nil)
    local function onToggle2(_)
        press(toggle2, 2)
    end

    local toggle3 = dofile('data/scripts/ui/default_toggle.lua')
    toggle3.init(resolution.find('toggle3'), nil)
    local function onToggle3(_)
        press(toggle3, 3)
    end

    local toggle4 = dofile('data/scripts/ui/default_toggle.lua')
    toggle4.init(resolution.find('toggle4'), nil)
    local function onToggle4(_)
        press(toggle4, 4)
    end

    local isWeb = love.system.getOS() == 'Web'
    local toggleFull
    local onToggleFull

    if isWeb then
        resolution.find('toggleFull').destroy()
        resolution.find('labelFull').destroy()
    else
        toggleFull = dofile('data/scripts/ui/default_toggle.lua')
        toggleFull.init(resolution.find('toggleFull'), nil)
        onToggleFull = function(_)
            press(toggleFull, 0)
        end
    end

    activeToggle, activeValue = _activateInitialResolution(toggle1, toggle2, toggle3, toggle4, toggleFull)

    resolution.find('toggle1').getComponent('button').onMouseEnter.subscribe(_highlightResolution)
    resolution.find('toggle1').getComponent('button').onMouseExit.subscribe(_unhighlightResolution)
    toggle1.onToggle.subscribe(onToggle1)

    resolution.find('toggle2').getComponent('button').onMouseEnter.subscribe(_highlightResolution)
    resolution.find('toggle2').getComponent('button').onMouseExit.subscribe(_unhighlightResolution)
    toggle2.onToggle.subscribe(onToggle2)

    resolution.find('toggle3').getComponent('button').onMouseEnter.subscribe(_highlightResolution)
    resolution.find('toggle3').getComponent('button').onMouseExit.subscribe(_unhighlightResolution)
    toggle3.onToggle.subscribe(onToggle3)

    resolution.find('toggle4').getComponent('button').onMouseEnter.subscribe(_highlightResolution)
    resolution.find('toggle4').getComponent('button').onMouseExit.subscribe(_unhighlightResolution)
    toggle4.onToggle.subscribe(onToggle4)

    if not isWeb then
        resolution.find('toggleFull').getComponent('button').onMouseEnter.subscribe(_highlightResolution)
        resolution.find('toggleFull').getComponent('button').onMouseExit.subscribe(_unhighlightResolution)
        toggleFull.onToggle.subscribe(onToggleFull)
    end

    _ditherer.queueDitherIn(resolution.getComponent('mask'), index)
end

local function _incrementIndex(i)
    i = i + 1
    if i > 10 then
        i = 10
    end
    return i
end

local function _init()
    local isWeb = love.system.getOS() == 'Web'
    local i = 0
    _ditherer.queueDitherIn(_baseObject.getComponent('mask'), i)
    i = _incrementIndex(i)
    _spawnLabel('audioLabel', 'audio_label', i)
    i = _incrementIndex(i)
    _spawnSlider('overallVolume', 'overall_volume', i)
    i = _incrementIndex(i)
    _spawnSlider('effectVolume', 'effect_volume', i)
    i = _incrementIndex(i)
    _spawnSlider('musicVolume', 'music_volume', i)
    i = _incrementIndex(i)
    if not isWeb then
        _spawnToggle('playSoundInBackground', 'play_sound_bg', i)
        i = _incrementIndex(i)
    end
    _spawnToggle('disableDialogueSounds', 'disable_dialogue_sound', i)
    i = _incrementIndex(i)
    if not isWeb then
        _spawnLabel('graphicsLabel', 'graphics_label', i)
        i = _incrementIndex(i)
        _spawnLanguage(i)
		i = _incrementIndex(i)
        _spawnResolution(i)
        i = _incrementIndex(i)
        _spawnToggle('vSync', 'v_sync', i)
        i = _incrementIndex(i)
        _spawnSlider('crtStrength', 'crt_strength', i)
        i = _incrementIndex(i)
        _spawnToggle('chromaticAberration', 'chromatic_aberration', i)
        i = _incrementIndex(i)
        _spawnToggle('filmGrain', 'film_grain', i)
        i = _incrementIndex(i)
        _spawnToggle('disableGoalVisuals', 'disableGoalVisuals', i)
        i = _incrementIndex(i)
    end
    _spawnLabel('gameplayLabel', 'gameplay_label', i)
    i = _incrementIndex(i)
    _spawnToggle('skipAlreadySeen', 'skip_already_seen', i)
    i = _incrementIndex(i)
    _ditherer.executeDither()

    local closeButton = dofile('data/scripts/ui/default_button.lua')
    closeButton.init(_object.find('closeButton'))

    _closeButton = _object.find('closeButton/button').getComponent('button')
    _closeButton.onClick.subscribe(_close)
end

_init()

return settings
