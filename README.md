# 🎮 Game Mods & Mobile Ports

Repositório privado para versionamento de código-fonte modificado, traduções, portas para dispositivos móveis (Android APK), scripts de automação de build e sincronização multiplataforma de saves.

---

## 📂 Estrutura do Repositório

```text
game-mods-and-ports/
├── games/
│   └── monster-girl-encounters/          # Monster Girl Encounters Deluxe (PT-BR)
│       ├── src/                          # Código-fonte modificado completo (Lua, sprites, dados)
│       ├── build_scripts/                # Scripts para compilar Windows (.exe) e Android (.apk assinado)
│       ├── docs/                         # Planejamento, documentação de features e engenharia reversa
│       └── saves/                        # Backups versionados de progresso e configurações
└── tools/
    └── save_sync.py                      # Utilitário para backup/restauração de saves (PC <-> Celular)
```

---

## 🚀 Como Lidar com Atualizações dos Jogos Originais

Quando um jogo receber uma nova atualização (ex: nova versão do desenvolvedor oficial):

1. **Baixar a nova versão original do jogo.**
2. **Comparar as alterações com o `src/`:**
   ```bash
   # Comparar o código original novo com as modificações deste repositório
   git diff
   ```
3. **Mesclar as novidades:**
   - Adicionar os novos assets/mecânicas do desenvolvedor.
   - Preservar os módulos de tradução (`pt_br.csv`) e as modificações personalizadas (novos modos, hacks, sandbox).
4. **Recompilar:**
   - Execute os scripts em `build_scripts/` para gerar os novos executáveis de PC e APK do Android.
5. **Commitar no Git:**
   - Registre a nova versão no histórico (`git commit -m "Atualizado para versão X.Y com mods mantidos"`).

---

## 📲 Sincronização de Saves (PC $\leftrightarrow$ Celular)

Para manter o seu progresso entre o computador e o smartphone:

### No Computador (via script)
- **Fazer backup do progresso atual para o Git:**
  ```bash
  python tools/save_sync.py --backup
  git add games/monster-girl-encounters/saves/
  git commit -m "Update save progress"
  git push
  ```
- **Restaurar um save baixado do repositório para o PC:**
  ```bash
  python tools/save_sync.py --restore
  ```

### No Celular (Android)
- O LÖVE salva os arquivos em:
  ```text
  /sdcard/Android/data/org.love2d.android/files/save/monster_girl_encounters/game.sav
  ```
- Basta copiar o arquivo `game.sav` de/para essa pasta usando qualquer gerenciador de arquivos no celular ou via USB.

---

## 📦 Como Compilar

### Monster Girl Encounters (MGE Deluxe)
- **Windows Executável:**
  ```bash
  python games/monster-girl-encounters/build_scripts/build_windows_exe.py
  ```
- **Android APK (v1, v2 e v3 assinados e zipaligned):**
  ```bash
  python games/monster-girl-encounters/build_scripts/build_signed_apk.py
  ```
