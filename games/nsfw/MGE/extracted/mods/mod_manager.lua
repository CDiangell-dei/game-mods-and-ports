-- MOD MANAGER
-- Resolve UMA vez (no boot do jogo) quais mods estao ativos e entrega ao jogo
-- apenas o que esta ativo. O resto do projeto nunca precisa perguntar
-- "este mod esta ligado?": ele so chama manager.call / manager.filter.
--
-- Uso nos scripts do jogo (sandbox):
--     local mods = require('mods/mod_manager.lua')
--     mods.call('onAlgumaCoisa', arg1, arg2)          -- executa os hooks dos mods ativos
--     valor = mods.filter('aoCalcularX', valor, ctx)  -- cada mod ativo pode alterar o valor
--
-- Se nenhum mod ativo registrou o hook, a chamada nao faz nada (custo minimo).
--
-- mod.json (sem textos: nome, descricao e condicao ficam nos CSV de cada mod, ver abaixo):
--   order            posicao na lista (menor primeiro)
--   default          true = ligado assim que desbloqueado (padrao: false)
--   unlock           condicao para liberar o mod na lista (sem isso o mod ja vem liberado):
--                      { "progress": "standard_complete", "value": 1 }   progresso salvo do jogo
--                      { "collection": true }                            todos os itens do Acervo
--   platforms        { 'Windows', 'OS X', 'Linux', 'Android' }: so aparece nessas plataformas
--   comingSoon       true = aparece na lista mas nao pode ser ligado (mod em desenvolvimento)
--
-- Textos de cada mod (pasta text/ dentro do mod), sempre en_us e pt_br:
--   info_<idioma>.csv   SEMPRE carregado: mod_<id>_name, mod_<id>_description, mod_<id>_unlock
--   game_<idioma>.csv   carregado so com o mod ATIVO: textos novos/alterados dentro do jogo

local manager = {}

-- Modo de desenvolvimento: true libera todos os mods (ignora as condicoes de desbloqueio).
-- Deve ficar false nas versoes entregues aos jogadores.
local DEV_UNLOCK_ALL = true

local MODS_ROOT = 'mods/list/'
local SETTING_PREFIX = 'mod_' -- settings.json: mod_<id> = 1 (ligado) / 2 (desligado) / 0 (usa o padrao)
local STORED_ON = 1
local STORED_OFF = 2

local _catalog = nil   -- todos os mods desta plataforma (usado pela tela de Mods)
local _booted = false
local _active = {}     -- snapshot dos mods ativos, montado no boot
local _hooks = {}      -- nomeDoHook -> lista de funcoes (somente mods ativos)
local _systemHooks = {} -- nomeDoHook -> funcoes do proprio sistema (rodam sempre, mesmo sem mod ativo)
local _current = nil   -- mod sendo carregado agora (ver manager.current())

------------------------------------------------------------------------
-- Catalogo (todos os mods instalados, ativos ou nao)
------------------------------------------------------------------------

local function _supportsPlatform(manifest)
    if type(manifest.platforms) ~= 'table' then
        return true
    end
    local os = love.system.getOS()
    for _, platform in ipairs(manifest.platforms) do
        if platform == os then
            return true
        end
    end
    return false
end

local function _readMod(id)
    local manifest = game.data.loadJson(MODS_ROOT .. id .. '/mod.json')
    if type(manifest) ~= 'table' or not _supportsPlatform(manifest) then
        return nil
    end
    local folder = MODS_ROOT .. id .. '/'
    local icon = nil
    if love.filesystem.getInfo(folder .. 'icon.png') ~= nil then
        icon = folder .. 'icon.png'
    end
    return {
        id = id,
        folder = folder,
        nameKey = 'mod_' .. id .. '_name',
        descriptionKey = 'mod_' .. id .. '_description',
        unlockKey = 'mod_' .. id .. '_unlock',
        order = manifest.order or 100,
        icon = icon,
        version = manifest.version,
        default = manifest.default == true,
        unlock = manifest.unlock,
        comingSoon = manifest.comingSoon == true,
        hasScript = love.filesystem.getInfo(folder .. 'mod.lua') ~= nil,
    }
end

function manager.getAll()
    if _catalog ~= nil then
        return _catalog
    end
    _catalog = {}
    local ids = love.filesystem.getDirectoryItems('mods/list')
    for _, id in ipairs(ids) do
        local mod = _readMod(id)
        if mod ~= nil then
            table.insert(_catalog, mod)
        end
    end
    table.sort(_catalog, function(a, b)
        if a.order ~= b.order then
            return a.order < b.order
        end
        return a.id < b.id
    end)
    return _catalog
end

function manager.getName(id)
    for _, mod in ipairs(manager.getAll()) do
        if mod.id == id then
            return game.text.getText(mod.nameKey)
        end
    end
    return id
end

------------------------------------------------------------------------
-- Desbloqueio e estado salvo (usado pela tela de Mods e pelo boot; o jogo NAO usa isto)
------------------------------------------------------------------------

-- em desenvolvimento: aparece na lista, mas nunca fica ativo
function manager.isUnavailable(mod)
    return mod.comingSoon == true
end

-- a condicao de desbloqueio do mod foi cumprida?
function manager.isUnlocked(mod)
    local unlock = mod.unlock
    if unlock == nil or DEV_UNLOCK_ALL then
        return true
    end
    if unlock.collection then
        return require('mods/unlocks.lua').isCollectionComplete()
    end
    if unlock.progress ~= nil then
        return game.data.getProgress(unlock.progress) == (unlock.value or 1)
    end
    return true
end

-- texto da condicao para a tela de Mods (com o progresso do Acervo, quando for o caso)
function manager.getUnlockText(mod)
    local text = game.text.getText(mod.unlockKey)
    if mod.unlock ~= nil and mod.unlock.collection then
        local obtained, total = require('mods/unlocks.lua').collectionStatus()
        text = text .. ' (' .. tostring(obtained) .. '/' .. tostring(total) .. ')'
    end
    return text
end

local function _stored(mod)
    local stored = game.data.getSetting(SETTING_PREFIX .. mod.id)
    if stored == STORED_ON then
        return true
    elseif stored == STORED_OFF then
        return false
    end
    return mod.default
end

function manager.isEnabled(mod)
    if manager.isUnavailable(mod) or not manager.isUnlocked(mod) then
        return false
    end
    return _stored(mod)
end

function manager.setEnabled(mod, isOn)
    if manager.isUnavailable(mod) or not manager.isUnlocked(mod) then
        return
    end
    game.data.setSetting(SETTING_PREFIX .. mod.id, isOn and STORED_ON or STORED_OFF)
end

------------------------------------------------------------------------
-- Boot: roda uma vez por sandbox (titulo e inicio de jogo)
------------------------------------------------------------------------

local function _addTexts(folder, prefix)
    -- en_us primeiro e pt_br depois, para o refresh do tradutor pegar os dois
    for _, lang in ipairs({ 'en_us', 'pt_br' }) do
        local path = folder .. prefix .. lang .. '.csv'
        if love.filesystem.getInfo(path) ~= nil then
            game.text.addTranslation(lang, path)
        end
    end
end

local function _registerHooks(mod, definition)
    local hooks = definition.hooks or definition
    for name, fn in pairs(hooks) do
        if type(fn) == 'function' then
            _hooks[name] = _hooks[name] or {}
            table.insert(_hooks[name], { mod = mod.id, fn = fn })
        end
    end
end

local function _activate(mod)
    _current = mod
    _addTexts(mod.folder .. 'text/', 'game_') -- textos do jogo SO existem se o mod estiver ativo
    if mod.hasScript then
        local definition = dofile(mod.folder .. 'mod.lua')
        if type(definition) == 'table' then
            _registerHooks(mod, definition)
        else
            game.debug.logWarning('Mod ' .. mod.id .. ': mod.lua deve retornar uma tabela.')
        end
    end
    _current = nil
    table.insert(_active, mod)
end

-- Hook do sistema: roda sempre (ate sem mods ativos), antes dos hooks dos mods.
-- Usado pelo rastreamento de desbloqueios (mods/unlocks.lua).
function manager.addSystemHook(hookName, fn)
    _systemHooks[hookName] = _systemHooks[hookName] or {}
    table.insert(_systemHooks[hookName], fn)
end

function manager.boot()
    if _booted then
        return
    end
    _booted = true
    _addTexts('mods/texts/', '') -- textos da propria tela de Mods
    for _, mod in ipairs(manager.getAll()) do
        _addTexts(mod.folder .. 'text/', 'info_') -- nome, descricao e condicao (sempre)
    end
    require('mods/unlocks.lua').register(manager)
    local safe = require('mods/lib/safe_math.lua')
    manager.addSystemHook('laggingIncrement', function(increment, difference, current)
        return safe.lagStep(increment, difference, current)
    end)
    manager.addSystemHook('sanitizeNumber', function(value, kind)
        if type(value) ~= 'number' then
            return value
        end
        if kind == 'progress' then
            if value ~= value then
                return 0
            end
            return math.max(0, math.min(value, 1e9))
        end
        return safe.sanitize(value)
    end)
    for _, mod in ipairs(manager.getAll()) do
        if manager.isEnabled(mod) then -- unica checagem de ativo/inativo do jogo
            _activate(mod)
        end
    end
    manager.call('onContentLoaded') -- apos add_tiles / add_buffs / add_encounters
end

------------------------------------------------------------------------
-- API para o jogo e para os mods
------------------------------------------------------------------------

function manager.getActive()
    return _active
end

function manager.hasActive()
    return #_active > 0
end

-- Dentro de mod.lua: local MOD = require('mods/mod_manager.lua').current()
function manager.current()
    return _current
end

local function _run(list, hookName, ...)
    for _, entry in ipairs(list) do
        local isTable = type(entry) == 'table'
        local ok, err = pcall(isTable and entry.fn or entry, ...)
        if not ok then
            local owner = isTable and entry.mod or 'sistema'
            game.debug.logError('Hook ' .. hookName .. ' falhou (' .. tostring(owner) .. '): ' .. tostring(err))
        end
    end
end

function manager.call(hookName, ...)
    local system = _systemHooks[hookName]
    if system ~= nil then
        _run(system, hookName, ...)
    end
    local list = _hooks[hookName]
    if list ~= nil then
        _run(list, hookName, ...)
    end
end

function manager.filter(hookName, value, ...)
    local system = _systemHooks[hookName]
    if system ~= nil then
        -- observadores do sistema: veem o valor, nunca o alteram
        for _, fn in ipairs(system) do
            local ok, err = pcall(fn, value, ...)
            if not ok then
                game.debug.logError('Hook ' .. hookName .. ' falhou (sistema): ' .. tostring(err))
            end
        end
    end
    local list = _hooks[hookName]
    if list == nil then
        return value
    end
    for _, entry in ipairs(list) do
        local ok, result = pcall(entry.fn, value, ...)
        if ok then
            if result ~= nil then
                value = result
            end
        else
            game.debug.logError('Mod ' .. entry.mod .. ' falhou em ' .. hookName .. ': ' .. tostring(result))
        end
    end
    return value
end

return manager
