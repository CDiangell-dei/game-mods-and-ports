# Adulttale — Luta da Muffet (Standalone Edition + PT-BR)

- **Jogo Base**: [Adulttale (`v0.1.33.1`)](https://adulttale.itch.io/adulttale) (GameMaker Studio 2023+ YYC x86_64)
- **Diretório Local**: `C:\Jogos\Adulttale-Muffet`
- **Idioma**: Português (Brasil) — 100% traduzido

## O que é esta versão Standalone?
Esta edição isolada (construída via engenharia reversa com **REA** sobre o executável nativo YYC `Adulttale.exe` e `data.win`) separa a **Luta da Muffet** (`muffet_fight`) e o **Clube da Muffet** (`rm_strip_enter` / `rm_strip_hallway`) em um jogo independente:

1. **Botão `"Lutar com Muffet"` (Novo Jogo -> Sim)**:
   - Inicia **imediatamente** a luta principal completa contra a Muffet (`BattleRoom` -> `battle_start("muffet_fight", [427.0, 224.0], 0, "muffet_fight")`) com `global.muffet_fight_init = false`, incluindo toda a introdução, diálogos, fases, Shadow Rabbit e opção de chamar a Chara.
2. **Botão `"Clube da Muffet"` (Continuar -> Slot 1)**:
   - Carrega o save pré-configurado (`global_save_0.ini`, já equipado com `charas_promise`, itens de cura e moedas) e posiciona o jogador **diretamente dentro da entrada do Clube da Muffet (`rm_strip_enter`, `Room 26`)**, em frente à Muffet, à estrela de Save, à cama e à porta direita para o corredor (`rm_strip_hallway`, `Room 27`), permitindo repetir a luta quantas vezes quiser.
3. **Fluxo Isolado (Derrota e Saída)**:
   - Caso o jogador perca a luta contra a Muffet, o jogo renasce diretamente em `rm_strip_enter` (`Room 26`) em frente à Muffet.
   - Sair pela porta esquerda de `rm_strip_enter` retorna diretamente ao Menu Principal (`rm_mainmenu_new`, `Room 14`).

## Patches Binários Aplicados (`Adulttale.exe`)
| RVA (`.text`) | Offset (`raw`) | Descrição |
|---|---|---|
| `0x26d7e0` | `0x26cbe0` | `E9 2B 74 06 00` (`jmp 0x2d4bb0`) — Redireciona `Novo Jogo -> Sim` (`anon@7098@gml_Object_obj_gui_menu_Create_0`) direto para o disparador de batalha da Muffet (`anon@18@gml_Object_obj_prop_interact_Create_0`). |
| `0x2d4cd2` | `0x2d40d2` | `48 8D 15 CF 1D ED 00` — Passa `"muffet_fight"` (`0x11a6aa8`) como 4º argumento de `gml_Script_battle_start`. |
| `0x2d4d15` | `0x2d4115` | `0F 57 C0 90 90 90 90` (`xorps xmm0, xmm0`) — Define `global.muffet_fight_init = false` (`0.0`) para executar a luta completa. |
| `0x26a2a0` | `0x2696a0` | Altera a sala padrão de `Continuar` (sem save) de `rm_main` (`0x0d`) para `rm_strip_enter` (`0x1a`). |
| `0x3302a1` / `0x334094` | `0x32f6a1` / `0x333494` | Força o `SaveManager` a carregar qualquer slot diretamente na sala `rm_strip_enter` (`0x1a = Room 26`). |
| `0x3fd778` | `0x3fcb78` | Altera a sala de derrota na luta da Muffet (`Timeline_tl_dialogue_muffet_fight_player_death_0_4`) de `LoadSave` (`0x03`) para `rm_strip_enter` (`0x1a`). |
| `0x182359` | `0x181759` | Altera a porta de saída esquerda de `rm_strip_enter` de `rm_hotland_3` (`0x0c`) para `rm_mainmenu_new` (`0x0e`). |

## Como Reconstruir ou Atualizar
```powershell
# Reconstituir arquivos grandes (>95 MB) após clonar o repositório:
python ..\..\..\tools\split_reassemble.py --reassemble

# Ou reconstruir a edição standalone a partir da pasta base C:\Jogos\Adulttale:
python scripts\build_standalone_muffet.py --source-dir "C:\Jogos\Adulttale" --target-dir "C:\Jogos\Adulttale-Muffet"
```
