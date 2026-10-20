# 🐺 Monster Girl Encounters (MGE Deluxe)

Versão aprimorada com tradução integral para Português do Brasil (PT-BR), portabilidade para dispositivos móveis (Android APK), desbloqueio de galeria, criador de builds sandbox e correções de estabilidade.

---

## 🔗 Links Rápidos e Oficiais

* 🌐 **Página Oficial do Jogo (Reinesoft):** [https://reinesoft.itch.io/monster-girl-encounters](https://reinesoft.itch.io/monster-girl-encounters)
* 🛠️ **Mod Base de Referência (ks-k-dev):** [https://maybeks-k-dev.itch.io/mge-mod-by-ks-k-dev](https://maybeks-k-dev.itch.io/mge-mod-by-ks-k-dev)

---

## ✨ Modificações & Melhorias Incluídas

1. **Tradução Completa (PT-BR):**
   - 76 itens, descrições, diálogos, telas de vitória/derrota e interfaces das 9 garotas monstro traduzidos.
2. **Galeria 100% Desbloqueada:**
   - Todas as cenas (introduções, combates, vitórias e animações) acessíveis no Acervo sem restrições.
3. **Modos de Jogo Separados no Menu:**
   - **Modo História:** Progressão clássica canônica de 13 andares.
   - **Modo Sem Fim (Endless Hub):** Menu dedicado ao modo infinito com Criador de Builds Sandbox.
4. **Criador de Builds Sandbox:**
   - Mochila interativa com expansão dinâmica de linhas ao equipar itens de slot (ex: *Bolsa Espaçosa*).
   - Ouro inicial configurável (10 G, 1.000 G, 50.000 G, 999.999 G).
5. **Modo Turbo (1x / 2x / 4x):**
   - Controle dinâmico de velocidade das batalhas e animações.
6. **Dádivas do Ciclo (*Cycle Rewards*):**
   - Escolha de upgrade permanente a cada 13 andares no modo sem fim.
7. **Port Android Completo:**
   - APK assinado com esquemas oficiais **v1, v2 e v3** e alinhamento de 4 bytes (`zipalign`).
8. **Correção de Tela Cheia no Windows:**
   - Suporte nativo a telas modernas (resolução de desktop automática sem falhas de driver).

---

## 🛠️ Como Compilar

* **Gerar Executável Windows:**
  ```bash
  python games/MGE/build_scripts/build_windows_exe.py
  ```
* **Gerar APK Android:**
  ```bash
  python games/MGE/build_scripts/build_signed_apk.py
  ```
