# LoveManiac — Tradução PT-BR & Saves

Tradução completa para Português Brasileiro (PT-BR), backup de saves e ferramentas de atualização para **LoveManiac** (desenvolvido por **Team Nebula**).

---

## 🔗 Links Oficiais do Jogo

- **Página Oficial (Itch.io):** [https://team-nebula.itch.io/lovemaniac](https://team-nebula.itch.io/lovemaniac)
- **Criador (Team Nebula):** [https://team-nebula.itch.io/](https://team-nebula.itch.io/)
- **Versão Base da Tradução:** `v0.3.6` (Godot 4.5.stable)
- **Pasta Local Padrão:** `C:\Jogos\LoveManiac`
- **Pasta de Saves (Windows):** `%APPDATA%\Godot\app_userdata\Love Maniac\save\`

---

## 📁 Estrutura no Repositório

```
LoveManiac/
├── lang/
│   ├── pt_br.json              # Dicionário completo PT-BR (919 entradas em 20 arquivos .translation)
│   └── en_es_reference.json    # Dump original EN/ES com hashes e buckets para diff de atualizações
├── saves/
│   ├── meta.json               # Configurações globais e desbloqueios
│   └── slot_0.json             # Progresso do Slot 0
├── scripts/
│   └── update_and_apply_ptbr.py # Decodificador/reconstrutor de recursos OptimizedTranslation no PCK v3
└── README.md
```

---

## 🛠️ Arquitetura Técnica

- O jogo utiliza **Godot Engine 4.5** com pacotes `PCK v3` (`flags=2`, `file_base=112`, `dir_offset` dinâmico no cabeçalho).
- Os textos ficam compilados em 20 grupos de recursos binários `OptimizedTranslation` (`.en.translation`, `.es.translation` / `.esp.translation`, `.ru.translation`), utilizando contêineres `RSRC` e `RSCC` (compressão Zstandard em blocos de 4 KB) e compressão de strings `Smaz`.
- O script [`update_and_apply_ptbr.py`](scripts/update_and_apply_ptbr.py) lê a tabela de hashes de cada `OptimizedTranslation`, reconstrói os recursos `.en.translation`, `.es.translation` e `.esp.translation` com strings UTF-8 em Português Brasileiro (`comp_size == uncomp_size`), anexa os recursos atualizados ao final do `.pck` e atualiza a tabela de diretório e os hashes MD5 em menos de 1 segundo, preservando um backup `.pck.orig`.

---

## 🚀 Como Atualizar Quando Sair Versão Nova

Quando uma nova versão for lançada em [team-nebula.itch.io/lovemaniac](https://team-nebula.itch.io/lovemaniac):

1. Extraia o novo `.exe` e `.pck` na pasta `C:\Jogos\LoveManiac` (o script detecta automaticamente o `LoveManiac *.pck` mais recente).
2. Verifique e mescle novas chaves adicionadas pelos desenvolvedores:
   ```powershell
   python "C:\Jogos\game-mods-and-ports\games\nsfw\LoveManiac\scripts\update_and_apply_ptbr.py" --merge
   ```
   - Textos que já existiam na versão anterior são reaproveitados automaticamente (mesmo que mudem de arquivo).
   - Textos inéditos são adicionados em `lang/pt_br.json` com o prefixo `[TODO_PTBR]`.
3. Traduza eventuais chaves `[TODO_PTBR]` em `lang/pt_br.json` e aplique o patch no novo `.pck`:
   ```powershell
   python "C:\Jogos\game-mods-and-ports\games\nsfw\LoveManiac\scripts\update_and_apply_ptbr.py" --apply
   ```
