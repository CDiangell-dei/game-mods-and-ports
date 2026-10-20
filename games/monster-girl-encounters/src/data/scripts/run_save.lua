-- SALVAR / CONTINUAR PARTIDA (fora da linha de mods)
--
-- Um checkpoint e gravado toda vez que o mapa abre para escolher o proximo encontro
-- (game_control.completeEncounter). Sair da partida (menu, fechar o app) volta para esse ponto.
-- O save e apagado quando a partida termina (vitoria ou derrota) ou quando uma nova comeca.
--
-- Estado de tiles e buffs: eles guardam contadores em variaveis locais dos proprios scripts
-- (upvalues, ex: _counter, _levels). Elas sao lidas/escritas com debug.getupvalue/setupvalue,
-- somente as que comecam com "_" e guardam numero/texto/booleano. Nao precisa mexer em
-- cada tile para ele ser salvo.

local runSave = {}

local PATH = 'run.sav'
local VERSION = 1

local function _isPrimitive(value)
    local t = type(value)
    return t == 'number' or t == 'string' or t == 'boolean'
end

local function _isPlainTable(value)
    local count = 0
    for k, v in pairs(value) do
        count = count + 1
        if count > 64 then
            return false
        end
        local kt = type(k)
        if kt ~= 'string' and kt ~= 'number' then
            return false
        end
        if not _isPrimitive(v) then
            return false
        end
    end
    return true
end

local function _copy(value)
    if type(value) == 'table' then
        local copy = {}
        for k, v in pairs(value) do
            copy[k] = v
        end
        return copy
    end
    return value
end

local function _isFinite(value)
    return type(value) ~= 'number' or (value == value and value ~= math.huge and value ~= -math.huge)
end

-- le as variaveis locais ("_nome") de um tile/buff
local function _captureObject(object)
    local state = nil
    for _, fn in pairs(object) do
        if type(fn) == 'function' then
            local i = 1
            while true do
                local name, value = debug.getupvalue(fn, i)
                if name == nil then
                    break
                end
                if string.sub(name, 1, 1) == '_' then
                    local ok = _isPrimitive(value) or (type(value) == 'table' and _isPlainTable(value))
                    if ok and _isFinite(value) then
                        state = state or {}
                        state[name] = _copy(value)
                    end
                end
                i = i + 1
            end
        end
    end
    return state
end

local function _applyObject(object, state)
    if state == nil then
        return
    end
    for _, fn in pairs(object) do
        if type(fn) == 'function' then
            local i = 1
            while true do
                local name = debug.getupvalue(fn, i)
                if name == nil then
                    break
                end
                if state[name] ~= nil then
                    debug.setupvalue(fn, i, _copy(state[name]))
                end
                i = i + 1
            end
        end
    end
end

local function _captureStats()
    local stats = {}
    local tracker = require('data/scripts/stat_tracker.lua')
    for k, v in pairs(tracker) do
        if type(v) == 'number' then
            stats[k] = v
        end
    end
    return stats
end

local function _applyStats(stats)
    if stats == nil then
        return
    end
    local tracker = require('data/scripts/stat_tracker.lua')
    for k, v in pairs(stats) do
        if type(tracker[k]) == 'number' and type(v) == 'number' then
            tracker[k] = v
        end
    end
end

local function _activeModIds()
    local mods = require('mods/mod_manager.lua')
    local ids = {}
    for _, mod in ipairs(mods.getActive()) do
        table.insert(ids, mod.id)
    end
    return ids
end

------------------------------------------------------------------------

function runSave.exists()
    local info = love.filesystem.getInfo(PATH)
    return info ~= nil and info.type == 'file'
end

function runSave.clear()
    if runSave.exists() then
        love.filesystem.remove(PATH)
    end
end

function runSave.capture()
    local control = game.control
    local state = {
        version = VERSION,
        gameMode = game.data.getSetting('gameMode'),
        mods = _activeModIds(),
        run = control.captureRunState(),
        tiles = control.tiles.getSnapshot(),
        buffs = {},
        stats = _captureStats(),
        unlocks = require('mods/unlocks.lua').captureRun(), -- "numa unica partida" atravessa o save
    }
    for _, slot in ipairs(state.tiles.slots) do
        local tile = control.tiles.getTile(slot.index)
        if tile ~= nil then
            slot.state = _captureObject(tile)
        end
    end
    for i = 1, control.buffs.getCount() do
        local buff = control.buffs.getBuff(i)
        if buff ~= nil and buff.data ~= nil then
            table.insert(state.buffs, { key = buff.data.key, state = _captureObject(buff) })
        end
    end
    return state
end

function runSave.save()
    if game.control == nil then
        return
    end
    local ok, result = pcall(runSave.capture)
    if not ok then
        game.debug.logError('Save failed (capture): ' .. tostring(result))
        return
    end
    local written, err = love.filesystem.write(PATH, game.json.serialize(result))
    if not written then
        game.debug.logError('Save failed (write): ' .. tostring(err))
    end
end

-- devolve o save, ou nil se nao existe / esta corrompido / e de outra versao
function runSave.load()
    if not runSave.exists() then
        return nil
    end
    local contents = love.filesystem.read(PATH)
    if contents == nil then
        return nil
    end
    local ok, state = pcall(game.json.deserialize, contents)
    if not ok or type(state) ~= 'table' or state.version ~= VERSION or
        type(state.run) ~= 'table' or type(state.tiles) ~= 'table' then
        game.debug.logWarning('Saved run ignored (invalid file).')
        return nil
    end
    return state
end

-- nomes dos mods que o save usava e que agora estao desligados
function runSave.getMissingMods(state)
    local mods = require('mods/mod_manager.lua')
    local active = {}
    for _, mod in ipairs(mods.getActive()) do
        active[mod.id] = true
    end
    local missing = {}
    for _, id in ipairs(state.mods or {}) do
        if not active[id] then
            table.insert(missing, mods.getName(id))
        end
    end
    return missing
end

-- antes de game.control.init(): o que a UI le enquanto e montada
function runSave.restoreBeforeInit(state)
    game.data.setSetting('gameMode', state.gameMode or 0)
    game.control.restoreRunStatePreInit(state.run)
end

-- depois de game.control.init() e do stat_tracker
function runSave.restoreAfterInit(state)
    local control = game.control
    local data = require('data/scripts/data.lua')
    control.restoreRunStatePostInit(state.run)

    for _, entry in ipairs(state.buffs or {}) do
        local buffData = data.buffs[entry.key]
        if buffData ~= nil then
            control.buffs.add(buffData)
            _applyObject(control.buffs.getBuff(control.buffs.getCount()), entry.state)
        else
            game.debug.logWarning('Save: buff ' .. tostring(entry.key) .. ' no longer exists.')
        end
    end

    control.tiles.restoreSnapshot(state.tiles)
    for _, slot in ipairs(state.tiles.slots or {}) do
        local tile = control.tiles.getTile(slot.index)
        if tile ~= nil then
            _applyObject(tile, slot.state)
        end
    end

    control.restoreRunValues(state.run) -- luck, shield, gold (override what init changed)
    _applyStats(state.stats)
    require('mods/unlocks.lua').restoreRun(state.unlocks)
    control.trigger('onInventoryChange') -- tiles recompute values with the restored counters
end

return runSave
