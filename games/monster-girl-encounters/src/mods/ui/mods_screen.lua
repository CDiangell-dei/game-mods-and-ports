-- Tela de Mods: lista de mods com foto, titulo, descricao e botao de check.
-- Aberta pelo botao "Mods" do menu inicial (data/scripts/title_control.lua).
local manager = require('mods/mod_manager.lua')

local _object = game.object.instantiate('mods/ui/mods_screen.json')
local _ditherer = dofile('data/scripts/ui/staggered_dither.lua')
local DEFAULT_ICON = 'mods/ui/default_icon.png'

local function _close()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
    game.data.save() -- grava mod_<id> em settings.json
end

local LOCKED_TINT = 0.55

local function _spawnMod(mod, index, parent)
    local item = game.object.instantiate('mods/ui/mod_item.json', parent)
    item.name = mod.id

    game.object.setVisual(item.find('icon'), mod.icon or DEFAULT_ICON)

    -- nome e descricao vem dos CSV do mod (text/info_<idioma>.csv)
    local name = game.text.getText(mod.nameKey)
    item.find('title/shadow').getComponent('text').setText(name)
    item.find('title/text').getComponent('text').setText(name)
    item.find('description').getComponent('text').setText(game.text.getText(mod.descriptionKey))

    if manager.isUnavailable(mod) then
        -- em desenvolvimento: card apagado, sem clique
        item.find('icon').getComponent('image').setColor(LOCKED_TINT, LOCKED_TINT, LOCKED_TINT, 1)
        item.find('toggle').getComponent('image').setColor(LOCKED_TINT, LOCKED_TINT, LOCKED_TINT, 1)
        item.find('toggle/checkmark').getComponent('image').setColor(0, 0, 0, 0)
        item.find('lockNote').getComponent('text').setText(game.text.getText('mods_soon_note'))
    elseif not manager.isUnlocked(mod) then
        -- bloqueado: card apagado, sem clique, mostrando a condicao de desbloqueio
        item.find('icon').getComponent('image').setColor(LOCKED_TINT, LOCKED_TINT, LOCKED_TINT, 1)
        item.find('toggle').getComponent('image').setColor(LOCKED_TINT, LOCKED_TINT, LOCKED_TINT, 1)
        item.find('toggle/checkmark').getComponent('image').setColor(0, 0, 0, 0)
        local note = game.text.getText('mods_locked_prefix') .. ' ' .. manager.getUnlockText(mod)
        item.find('lockNote').getComponent('text').setText(note)
    else
        item.find('lockNote').destroy()
        local toggle = dofile('data/scripts/ui/default_toggle.lua')
        toggle.init(item.find('toggle'), nil)
        toggle.setIsOn(manager.isEnabled(mod))
        toggle.onToggle.subscribe(function(isOn)
            manager.setEnabled(mod, isOn)
        end)
    end

    _ditherer.queueDitherIn(item.getComponent('mask'), (index - 1) % 8)
end

local function _init()
    local closeButtonObject = _object.find('closeButton')
    local closeButton = dofile('data/scripts/ui/default_button.lua')
    closeButton.init(closeButtonObject)
    closeButtonObject.find('button').getComponent('button').onClick.subscribe(_close)

    local mods = manager.getAll()
    if #mods > 0 then
        _object.find('empty').destroy()
    end
    local parent = _object.find('items/viewport/content')
    for index, mod in ipairs(mods) do
        _spawnMod(mod, index, parent)
    end
    _ditherer.executeDither()

    local fader = dofile('data/scripts/ui/dither_fader.lua')
    fader.init(_object.getComponent('mask'), 0, true)
    fader.fadeTo(100, 0.2, nil)
end

_init()
