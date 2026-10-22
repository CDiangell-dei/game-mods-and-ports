# 🎮 Game Mods & Mobile Ports

Repositório privado para versionamento de código-fonte modificado, traduções, portas para dispositivos móveis (Android APK), scripts de automação de build e sincronização multiplataforma de saves.

---

## 🕹️ Categorias de Jogos Catalogados

### 🌟 Jogos Gerais & Convencionais (`games/geral/`)

| Jogo | Pasta | Links Oficiais & Mods | Status do Port / Mod |
| :--- | :--- | :--- | :--- |
| **Shadow of the Colossus** | [`games/geral/Shadow-of-the-Colossus/`](games/geral/Shadow-of-the-Colossus/) | • PS2Recomp Nativo x86-64<br>• Edição SCUS-974.72 PT-BR | • 60 FPS Nativos & Ultra-Widescreen<br>• GPU Dedicada Auto (NVIDIA/AMD)<br>• WASD nos Menus & Mira com Mouse<br>• Troca com Roda do Mouse<br>• Quick Save / Quick Load (F5/F9) |

---

### 🔞 Jogos Adultos & +18 (`games/nsfw/`)

| Jogo | Pasta | Links Oficiais & Mods | Status do Port / Mod |
| :--- | :--- | :--- | :--- |
| **Monster Girl Encounters** | [`games/nsfw/MGE/`](games/nsfw/MGE/) | • [Página Oficial (Reinesoft)](https://reinesoft.itch.io/monster-girl-encounters)<br>• [MGE Mod (ks-k-dev)](https://maybeks-k-dev.itch.io/mge-mod-by-ks-k-dev) | • Tradução PT-BR Completa<br>• APK Android (v1+v2+v3 assinado)<br>• Galeria 100% Desbloqueada<br>• Modo Sem Fim & Criador Sandbox |

---

## 📂 Estrutura do Repositório

```text
game-mods-and-ports/
├── games/
│   ├── geral/                                    # Jogos Convencionais / Livres
│   │   └── Shadow-of-the-Colossus/               # Shadow of the Colossus Port Nativo PC (PT-BR)
│   │       ├── GUIA_DO_JOGO_E_CONTROLES.txt      # Guia oficial de comandos e dicas rápidas
│   │       ├── README.md                         # Documentação técnica e controles completos
│   │       ├── launchers/                        # Scripts silenciosos (.vbs), Play.bat e sotc.ini
│   │       ├── patches/                          # Perfis e mapa de símbolos para SCUS-974.72
│   │       ├── src/                              # C++ modificado (GPU dedicada, mira mouse, menus)
│   │       └── build_scripts/                    # Script de compilação automatizada x64
│   │
│   └── nsfw/                                     # Jogos Adultos (+18)
│       └── MGE/                                  # Monster Girl Encounters Deluxe (PT-BR)
│           ├── README.md                         # Documentação específica, links e comandos
│           ├── src/                              # Código-fonte modificado completo (Lua, sprites, dados)
│           ├── build_scripts/                    # Scripts para compilar Windows (.exe) e Android (.apk)
│           ├── docs/                             # Planejamento detalhado de expansão
│           └── saves/                            # Backups versionados de progresso e configurações
│
└── tools/
    └── save_sync.py                              # Utilitário para backup/restauração de saves (PC <-> Celular)
```

---

## 📲 Downloads Rápidos (Releases)

Para baixar os arquivos prontos diretamente no celular ou no computador:
* 👉 **[Página de Releases do Repositório](https://github.com/CDiangell-dei/game-mods-and-ports/releases)**
  * **Android APK:** [`Monster_Girl_Encounters_PTBR.apk`](https://github.com/CDiangell-dei/game-mods-and-ports/releases/download/v1.0.0-mge-deluxe/Monster_Girl_Encounters_PTBR.apk)
  * **Windows ZIP:** [`MGE_Deluxe_Windows_PTBR.zip`](https://github.com/CDiangell-dei/game-mods-and-ports/releases/download/v1.0.0-mge-deluxe/MGE_Deluxe_Windows_PTBR.zip)

---

## 🔄 Sincronização de Saves (PC $\leftrightarrow$ Celular)

### No Computador
- **Fazer backup do save do PC para o Git:**
  ```bash
  python tools/save_sync.py --backup
  git add games/nsfw/MGE/saves/
  git commit -m "Update save progress"
  git push
  ```
- **Restaurar save baixado do repositório para o jogo no PC:**
  ```bash
  python tools/save_sync.py --restore
  ```

### No Celular (Android)
- Caminho padrão do save no armazenamento do aparelho:
  ```text
  /sdcard/Android/data/org.love2d.android/files/save/monster_girl_encounters/game.sav
  ```
- Basta copiar o arquivo `game.sav` de/para essa pasta usando qualquer gerenciador de arquivos ou cabo USB.
