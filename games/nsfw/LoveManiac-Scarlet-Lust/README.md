# LoveManiac: Scarlet Lust — Tradução PT-BR

Tradução completa para Português Brasileiro (PT-BR) e ferramentas de atualização para **LoveManiac: Scarlet Lust** (desenvolvido por **Team Nebula**).

---

## 🔗 Links Oficiais do Jogo

- **Página Oficial (Itch.io):** [https://team-nebula.itch.io/lovemaniac-scarlet-lust](https://team-nebula.itch.io/lovemaniac-scarlet-lust)
- **Criador (Team Nebula):** [https://team-nebula.itch.io/](https://team-nebula.itch.io/)
- **Versão Base da Tradução:** `v0.1.43`
- **Pasta Local Padrão:** `C:\Jogos\LoveManiac-Scarlet-Lust`

---

## 📁 Estrutura no Repositório

```
LoveManiac-Scarlet-Lust/
├── lang/
│   ├── pt_br.json              # Tradução completa em Português Brasileiro (144 diálogos + 22 blocos de UI)
│   └── en_es_reference.json    # Referência original (EN/ES) da lista Dialog para diff entre versões
├── scripts/
│   └── update_and_apply_ptbr.py # Script para checar novas versões, mesclar e aplicar o patch no project.json
└── README.md
```

---

## 🎮 Controles (Esquema Duplo: Clássico + WASD)

O patch injeta automaticamente em `www/index.html` suporte simultâneo ao esquema original e ao novo esquema confortável:

| Ação | Esquema Novo (Adicionado) | Esquema Original (Mantido) |
| :--- | :--- | :--- |
| **Mover (Overworld / Alma em Combate / Menus)** | `W`, `A`, `S`, `D` | Setas (`↑`, `←`, `↓`, `→`) |
| **Confirmar / Interagir / Avançar Diálogo** | `Espaço` (`Space`) | `Z` |
| **Cancelar / Voltar / Pular Texto / Correr** | `Shift` | `X` |
| **Inventário** | `E` | `C` |

---

## 🛠️ Arquitetura Técnica

O jogo é empacotado com **TurboWarp / PenguinMod (Scratch 3)** sobre **WebView2**:
- Todo o código-fonte, variáveis, listas e textos de interface ficam em `www/assets/project.json`.
- Os diálogos principais e do Overworld ficam armazenados na lista `Dialog` do `Stage` (`id: dF{5|W6`[c/nX[O53.t2`), onde índices ímpares (`1, 3, 5...`) são em Inglês e índices pares (`2, 4, 6...`) são em Espanhol, selecionados em tempo de execução via `índice + Language`.
- Os textos de combate, itens, menus e checagem ficam em blocos `looks_say`, `operator_join` e chamadas de procedimentos customizados nos sprites `Buttons//UI text`, `CharaText`, `Overworld//Textonbox` e `Stage`.
- O script [`update_and_apply_ptbr.py`](scripts/update_and_apply_ptbr.py) cria um backup automático (`www/assets/project.json.orig`) e injeta a tradução PT-BR tanto na lista `Dialog` quanto nos blocos de UI.

---

## 🚀 Como Atualizar Quando Sair Versão Nova

Quando uma nova versão for lançada em [team-nebula.itch.io/lovemaniac-scarlet-lust](https://team-nebula.itch.io/lovemaniac-scarlet-lust):

1. Extraia a nova versão do jogo em `C:\Jogos\LoveManiac-Scarlet-Lust` (remova o `project.json.orig` antigo caso tenha substituído a pasta).
2. Execute o script de verificação e mesclagem:
   ```powershell
   python "C:\Jogos\game-mods-and-ports\games\nsfw\LoveManiac-Scarlet-Lust\scripts\update_and_apply_ptbr.py" --merge
   ```
   - Qualquer linha nova adicionada na atualização aparecerá marcada com `[TODO_PTBR]` em `lang/pt_br.json`.
3. Traduza as chaves `[TODO_PTBR]` (se houver) e aplique a tradução:
   ```powershell
   python "C:\Jogos\game-mods-and-ports\games\nsfw\LoveManiac-Scarlet-Lust\scripts\update_and_apply_ptbr.py" --apply
   ```
