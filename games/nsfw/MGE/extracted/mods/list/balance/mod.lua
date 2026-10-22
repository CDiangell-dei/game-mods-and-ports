-- BALANCE: mudancas de balanceamento de itens. Tudo aqui so existe com o mod ativo.
--
-- Como funciona:
--   * numeros simples (ouro do bracelete, multiplicadores de coroas...) sao trocados nos dados
--     do item (data.tiles[chave]) quando o jogo carrega (hook onContentLoaded);
--   * itens com logica nova trocam o campo "script" por uma copia modificada em mods/list/balance/tiles/;
--   * o multiplicador final da Multiferramenta usa o hook pumpExhaustion (depois de todos os itens);
--   * a Gema da Vida usa o evento onBeforeLifeLoss (game_control.endGame);
--   * os textos novos estao em text/game_en_us.csv / text/game_pt_br.csv (mesmas chaves do jogo, so valem com o mod).
-- Para ajustar um numero, mude a tabela abaixo (a descricao do item se atualiza sozinha).
local MOD = require('mods/mod_manager.lua').current()
local hooks = {}

local TILES = MOD.folder .. 'tiles/'

local function _set(key, fields, useScript)
    local data = require('data/scripts/data.lua')
    local tile = data.tiles[key]
    if tile == nil then
        game.debug.logWarning('Balance: item ' .. key .. ' nao existe.')
        return
    end
    for name, value in pairs(fields) do
        tile[name] = value
    end
    if useScript then
        tile.script = TILES .. key .. '.lua'
    end
end

function hooks.onContentLoaded()
    -- so numeros ---------------------------------------------------------------
    _set('cursed_charm',    { amount = 40 })                           -- Amuleto Pragueado: +40 de fadiga
    _set('golden_bracelet', { amount = 4 })                            -- Bracelete Dourado: 2 -> 4 de ouro
    _set('sparkling_crown', { modifier = 0.9, increase = 0.03 })       -- Coroa Brilhante: 0.1 -> 0.03
    _set('stone_crown',     { modifier = 1.5 })                        -- Coroa de Pedra: 1.3 -> 1.5
    _set('polymorphic_elixir', { max = 35 })                           -- Elixir Polimorfico: -10 ate +35 (era +30)
    _set('golden_scroll',   { increase = 0.005 })                      -- Pergaminho Dourado: 0.01 -> 0.005
    _set('leftovers',       { modifier = 2.5, chance = 1 })            -- Sobras: 1.3 -> 2.5x, 0.5% -> 1% (chance em %)
    _set('potted_clover',   { amount = 1 })                            -- Trevo em Vaso: 0.5 -> 1 ouro por espaco vazio

    -- logica nova (script do mod) ------------------------------------------------
    -- amount (+5 de sorte por rerrolagem) ja vem do jogo e continua valendo
    _set('spider_charm', { upChance = 33, upPercent = 5, downChance = 5, downPercent = 33, minLuck = 5 }, true)
    _set('bag_of_toys', { synergy = 5 }, true)
    _set('bottomless_bag_of_toys', { cutPercent = 50 }, true)
    _set('blessed_herbs', { amount = 5, modifier = 1.5 }, true)
    _set('gardening_gloves', { chance = 5 }, true)
    _set('half_slime', { chance = 50 }, true)
    _set('multitool', { final = 1.5 }, true)
    _set('sandwich', {}, true)
    -- Chapeu de Bobo: +6% do valor do multiplicador por item diferente (composto)
    _set('jester_hat', { modifier = 1.0, increasePercent = 6 }, true)
    -- Idolo e Elixir Dourado: A / S = bonus por ouro original (0.25 e 0.005); ver gold_scaling.lua
    _set('golden_idol', { amplitude = 2000, scale = 8000, decayPercent = 30, maxCostPercent = 1.5 }, true)
    _set('golden_elixir', { amplitude = 35, scale = 7000, decayPercent = 30, maxCostPercent = 1.5 }, true)
    -- Gema da Vida e a versao apagada que o jogo coloca no lugar dela
    _set('lifegem', { tolerance = 0.5, tolerancePercent = 50, breakChance = 50, progress = 0 }, true)
    _set('lifegem_off', { description = 'lifegem_off_description', remaining = 0, progress = 0 }, true)
end

-- Multiferramenta: multiplicador FINAL. O jogo chama este hook depois que todos os itens e
-- bencaos ja somaram/multiplicaram a fadiga do pump (encounters/battle.lua, battle.pump).
function hooks.pumpExhaustion(value, _, pumpData)
    local factor = 1
    for i = 1, game.control.tiles.getCount() do
        local tile = game.control.tiles.getTile(i)
        if tile ~= nil and tile.data.key == 'multitool' then
            factor = factor * (tile.data.final or 1)
            if pumpData ~= nil and pumpData.pumpers ~= nil then
                table.insert(pumpData.pumpers, tile) -- para o item animar no pump
            end
        end
    end
    return value * factor
end

return { hooks = hooks }
