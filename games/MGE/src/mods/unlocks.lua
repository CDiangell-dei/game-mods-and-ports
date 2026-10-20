-- DESBLOQUEIOS DE MODS
-- Rastreia, durante a partida, as condicoes que liberam mods na tela de Mods. Roda sempre
-- (mesmo com todos os mods desligados) porque os mods ainda estao bloqueados quando o jogador
-- cumpre as condicoes. Registrado como "hook do sistema" por mod_manager.boot().
--
--   unlock_no_limit   numa partida: EPP infinito + ouro no limite maximo do jogo (999.999)
--   unlock_hack_mode  numa partida: EPP infinito em 3 batalhas diferentes
--   unlock_rich_mode  numa partida: 10.000 de ouro gastos nas lojas
--   (balance: todos os itens do Acervo, verificado ao vivo; skip_battle / endless_mode:
--    progresso standard_complete do proprio jogo)
--
-- Valores a partir de INF_LIMIT contam como "infinito": o jogo mostra "inf" quando o numero
-- estoura o double, e o mod No Limit trava em 1e300 (safe_math), que tambem conta.
-- Todas as condicoes podem ser cumpridas no modo tradicional (valem em qualquer modo).
local unlocks = {}

local INF_LIMIT = 1e300
local GAME_GOLD_CAP = 999999   -- teto de ouro do jogo sem mods
local HACK_BATTLES = 3
local RICH_GOLD_SPENT = 10000

-- progresso da partida atual (salvo junto com o save da partida)
local _run = {
    infBattles = 0,
    reachedInf = 0,
    reachedMaxGold = 0,
    goldSpentInShops = 0,
}
local _lastInfBattle = nil

local function _grant(progressKey)
    if game.data.getProgress(progressKey) == 1 then
        return
    end
    game.data.setProgress(progressKey, 1)
    game.data.save()
    game.debug.log('Mod desbloqueado: ' .. progressKey)
end

local function _check()
    if _run.reachedInf == 1 and _run.reachedMaxGold == 1 then
        _grant('unlock_no_limit')
    end
    if _run.infBattles >= HACK_BATTLES then
        _grant('unlock_hack_mode')
    end
    if _run.goldSpentInShops >= RICH_GOLD_SPENT then
        _grant('unlock_rich_mode')
    end
end

-- Acervo: todos os itens que nao sao lixo (mesma regra da tela do Acervo)
function unlocks.collectionStatus()
    local data = require('data/scripts/data.lua')
    local obtained, total = 0, 0
    for _, tile in pairs(data.tiles) do
        if tile.subtype ~= 'junk' then
            total = total + 1
            if game.data.getProgress('obtained_' .. tile.key) == 1 then
                obtained = obtained + 1
            end
        end
    end
    return obtained, total
end

function unlocks.isCollectionComplete()
    local obtained, total = unlocks.collectionStatus()
    return total > 0 and obtained >= total
end

-- salvar e continuar: o progresso "numa unica partida" atravessa o save
function unlocks.captureRun()
    return {
        infBattles = _run.infBattles,
        reachedInf = _run.reachedInf,
        reachedMaxGold = _run.reachedMaxGold,
        goldSpentInShops = _run.goldSpentInShops,
    }
end

function unlocks.restoreRun(state)
    if type(state) ~= 'table' then
        return
    end
    for key, _ in pairs(_run) do
        if type(state[key]) == 'number' then
            _run[key] = state[key]
        end
    end
end

function unlocks.register(manager)
    -- EPP final de cada pump, antes de qualquer limite (battle.pump, hook pumpExhaustion)
    manager.addSystemHook('pumpExhaustion', function(value, battle)
        if type(value) ~= 'number' or value < INF_LIMIT then
            return
        end
        _run.reachedInf = 1
        if battle ~= _lastInfBattle then
            _lastInfBattle = battle
            _run.infBattles = _run.infBattles + 1
        end
        _check()
    end)
    -- ouro depois de cada ganho (game_control.gainGold)
    manager.addSystemHook('onGoldChanged', function(gold)
        if type(gold) == 'number' and gold >= GAME_GOLD_CAP then
            _run.reachedMaxGold = 1
            _check()
        end
    end)
    -- ouro gasto na loja: compras e rerrolagens (stat_tracker)
    manager.addSystemHook('onGoldSpentInShop', function(amount)
        if type(amount) == 'number' and amount > 0 then
            _run.goldSpentInShops = _run.goldSpentInShops + amount
            _check()
        end
    end)
end

return unlocks
