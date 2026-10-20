# Sistema de Mods

Tudo de mods fica em `mods/`, fora das pastas padrao do jogo.

```
mods/
  mod_manager.lua      resolve os mods ativos UMA vez e entrega ao jogo
  mod_boot.lua         chamado por data/scripts/init.lua (1 linha)
  unlocks.lua          rastreia as condicoes de desbloqueio (roda sempre, mesmo com mods bloqueados)
  lib/                 bibliotecas compartilhadas (safe_math.lua)
  texts/               textos da tela de Mods (en_us.csv, pt_br.csv)
  ui/                  tela de Mods (mods_screen.lua / .json, mod_item.json, sprites do check)
  list/<id_do_mod>/    UMA pasta por mod
      mod.json         metadados: ordem, padrao, desbloqueio, plataformas (sem textos)
      mod.lua          logica/hooks (opcional)
      icon.png         foto da lista, 90x90 (opcional)
      text/
        info_en_us.csv / info_pt_br.csv   SEMPRE carregado: nome, descricao e condicao de desbloqueio
        game_en_us.csv / game_pt_br.csv   so com o mod ATIVO: textos novos/alterados dentro do jogo
      ...              imagens e scripts proprios do mod
```

## Mods que vem no jogo e como desbloquear
Todas as condicoes podem ser cumpridas no modo tradicional. Mod bloqueado aparece apagado na lista, com a condicao
(e o progresso do Acervo, quando for o caso).

| mod | padrao | desbloqueio |
|---|---|---|
| skip_battle | ligado | vencer o modo Tradicional 1 vez |
| endless_mode | ligado | vencer o modo Tradicional 1 vez |
| auto_skip_dialog | desligado | liberado desde o inicio |
| sell_confirm | desligado | liberado desde o inicio (so PC; no Android a confirmacao de venda e nativa) |
| hack_mode | desligado | numa unica partida, EPP infinito em 3 batalhas diferentes |
| rich_mode | desligado | gastar 10.000 de ouro nas lojas numa unica partida |
| no_limit | desligado | numa unica partida, alcancar EPP infinito e o ouro maximo do jogo (999.999) |
| balance | desligado | ter desbloqueado todos os itens do Acervo |
| new_collection | - | em desenvolvimento (`comingSoon`): aparece na lista, nao pode ser ligado |

"Infinito" = o numero estourou o limite do jogo (aparece "inf"); valores a partir de 1e300 tambem contam.
O progresso de "numa unica partida" atravessa salvar e continuar. Os progressos ficam em `unlock_<mod>` no save do jogo.
Para testar sem cumprir as condicoes, troque `DEV_UNLOCK_ALL` para `true` no topo de `mod_manager.lua`
(deve ficar `false` nas versoes dos jogadores).

## mod.json (so metadados; os textos ficam nos CSV)
- `order`: posicao na lista
- `default`: `true` = ligado assim que desbloqueado (sem isso, desligado)
- `unlock`: condicao para liberar o mod. `{ "progress": "standard_complete", "value": 1 }` (progresso salvo do jogo)
  ou `{ "collection": true }` (todos os itens do Acervo). Sem `unlock` o mod ja vem liberado
- `platforms`: `["Windows","OS X","Linux","Android"]` - so aparece nessas plataformas
- `comingSoon`: `true` - aparece apagado na lista e nunca fica ativo (mod ainda em desenvolvimento)

## Textos dos mods
Tudo em CSV `Key,Text,Notes`, sempre en_us e pt_br, dentro de `list/<id>/text/`:
- `info_*.csv` (sempre carregado): `mod_<id>_name`, `mod_<id>_description`, `mod_<id>_unlock`
- `game_*.csv` (so com o mod ativo): textos novos ou alterados do jogo; mesma chave do jogo = sobrescreve
- Descricao: ate ~215 caracteres (cabe em 3 linhas no card). Condicao: ate ~45 caracteres (cabe em 1 linha com "Bloqueado:")

## Como o jogo recebe os mods
No boot de cada sandbox o `mod_manager` le `settings.json` **uma vez**, carrega so os mods
ativos (textos + `mod.lua`) e monta a tabela de hooks. Depois disso o jogo nunca pergunta
"esta ativo?": so chama `call`/`filter`, e se nenhum mod ativo registrou o hook, nada acontece.

```lua
local mods = require('mods/mod_manager.lua')
mods.call('onBattleStarted', battle)                 -- avisa os mods ativos
perItem = mods.filter('requiredExhaustionPerItem', perItem, loop)   -- mods podem alterar o valor
```

## Hooks ligados no jogo
| hook | onde | tipo |
|---|---|---|
| onContentLoaded | init.lua, depois de add_tiles/buffs/encounters | call |
| onGameModesBuilt(modes) | game_selector.init | call (mod acrescenta modos na lista) |
| maxFloors(valor) | game_control.init | filter |
| requiredExhaustionPerItem(valor, loop) | encounters/battle.lua | filter |
| onBattleStarted(battle) | encounters/battle.lua (startBattle) | call |
| onMainUiReady(parent) | ui/game_main.lua | call |
| dialogueAutoProgress(padrao) | dialogue/dialogue_handler.lua (talk) | filter |
| sellNeedsConfirmation(padrao) | ui/shop_helper.lua | filter |
| onRunStarted(control) | game_selector (so partida nova) | call |
| onGoldChanged(ouro) | game_control.gainGold | call |
| onGoldSpentInShop(valor) | stat_tracker (compras e rerrolagens) | call |
| maxGold(padrao) | game_control (gainGold, getMaxGold), battle.complete | filter |
| pumpExhaustion(valor, battle, pumpData) | encounters/battle.lua (pump), depois de todos os itens | filter |
| onBeforeLifeLoss(info) | evento de tiles, disparado em game_control.endGame (sem escudo); `info.absorbed = true` evita perder a vida | evento |
| sanitizeNumber(valor, tipo) | ouro, EPP, exaustao, requisito, progresso, numeros exibidos, estatisticas | filter |
| laggingIncrement(passo, diferenca, atual) | ui/game_main.lua (contador animado) | filter |

Para ligar outro hook basta colocar `mods.call/filter` no ponto desejado.

## Balance (mods/list/balance)
- `mod.lua`: numeros simples (ouro, multiplicadores, chances) sao trocados nos dados do item quando o jogo carrega;
  itens com logica nova trocam o `script` do item por uma copia em `tiles/`. Para ajustar um numero, mude a tabela
  em `hooks.onContentLoaded`; a descricao do item se atualiza sozinha.
- `text/game_en_us.csv` / `text/game_pt_br.csv`: descricao nova dos 20 itens (mesmas chaves do jogo, so valem com o mod).
- `gold_scaling.lua`: freios do Idolo Dourado e do Elixir Dourado, sem teto fixo e tudo por formula (sem regras de faixa):
  bonus de ouro logaritmico (`A * ln(1 + G/S)`, igual ao original com pouco ouro); desgaste hiperbolico que tira no maximo
  30% do bonus e desacelera (`0.70 + 0.30 / (1 + n/15)`, reinicia a cada batalha); custo em ouro por pump como funcao
  continua do ouro (`1.5% * u/(1+u)`, `u = (G/200000)^2 * (1 + n/10)`): quase nada com 10.000 de ouro ou menos, perto de
  1.5% para quem tem muito. A soma dos custos de todos os itens no mesmo pump nunca passa de 1.5% do ouro.
  Parametros no topo do arquivo e em `mod.lua` (`amplitude`, `scale`).
- Gema da Vida: o jogo troca a gema por `lifegem_off` quando a chefe das fadas aparece; o Balance tem script e texto
  proprios para a versao apagada (`tiles/lifegem_off.lua`, chave `lifegem_off_description`) e a gema volta a funcionar
  (contador em 0) quando o jogador vence a chefe.
- Itens: Amuleto da Aranha, Amuleto Pragueado, Bolsa de Brinquedos, Bolsa de Brinquedos sem Fundo, Bracelete Dourado,
  Chapeu de Bobo, Coroa Brilhante, Coroa de Pedra, Elixir Polimorfico, Ervas Benzidas, Luvas de Jardinagem, Meia Gosma,
  Multiferramenta, Pergaminho Dourado, Sanduiche, Sobras, Trevo em Vaso, Idolo Dourado, Elixir Dourado, Gema da Vida.

## Numeros gigantes (mods/lib/safe_math.lua)
Biblioteca com formulas para o jogo nao quebrar com numeros enormes (double de 64 bits):
`sanitize` (NaN vira 0, inf vira o maximo seguro 1e300), `add`, `mul`, `pow` e `ratio` refeitos em
logaritmo quando estouram, e `lagStep` (contador da tela rapido e sem travar por falta de precisao).
O mod `no_limit` usa essa biblioteca pelos hooks `maxGold`, `sanitizeNumber` e `laggingIncrement`.
Qualquer mod pode fazer `local safe = require('mods/lib/safe_math.lua')`.

## Criar um mod
1. Copie `list/auto_skip_dialog` para `list/<seu_id>`.
2. Edite `mod.json`.
3. Em `mod.lua` retorne `{ hooks = { nomeDoHook = function(...) end } }`.
   Use `local MOD = require('mods/mod_manager.lua').current()` para achar a pasta do mod (`MOD.folder`).
4. Textos: `text/info_*.csv` (nome, descricao, condicao) e, se precisar, `text/game_*.csv` (textos do jogo).

ATENCAO: o jogo roda os scripts num sandbox que libera so parte de `math`, `string` e `table`
(lista em `engine/sandbox.lua`). Por exemplo NAO existe `math.log10` (use `math.log(x) / math.log(10)`),
nem `math.pow` (use `^`). Chamar uma funcao fora da lista da erro no jogo, mesmo funcionando fora dele.
Um item que da erro nao derruba mais o pump dos outros: o erro vai para o log (`object_holder.lua`).

Estado salvo em `settings.json` como `mod_<id>`: 1 ligado, 2 desligado, 0/ausente = padrao do mod.
As mudancas valem na proxima vez que uma partida e iniciada.

# Salvar e continuar partida (fora dos mods)
- `data/scripts/run_save.lua` grava `run.sav` toda vez que o mapa abre para escolher o proximo encontro.
- Ao clicar em Iniciar, se existe save, a tela "Partida Salva" pergunta Continuar ou Nova Partida
  (antes da tela de modos).
- O save e apagado quando a partida termina (vitoria/derrota) ou quando uma nova comeca.
- Sair no meio de um encontro volta para o mapa do ultimo checkpoint.
- Se o save usava mods que agora estao desligados, o Continuar fica bloqueado e lista quais ligar.
- Tiles e buffs com contadores internos (variaveis locais `_nome`) sao salvos automaticamente.
