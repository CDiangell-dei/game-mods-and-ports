# 💜 Adulttale (Tradução Completa PT-BR)

Repositório da localização integral em Português do Brasil (PT-BR), utilitários de atualização entre versões e backup de saves para **Adulttale** (versão base atual: `v0.29.0.3`).

---

## 🔗 Links Rápidos e Oficiais

* 🌐 **Página Oficial do Jogo (Itch.io):** [https://adulttale.itch.io/adulttale](https://adulttale.itch.io/adulttale)

---

## ✨ Detalhes da Tradução & Estrutura

1. **Tradução 100% Completa (PT-BR):**
   - Todas as **1.045 chaves** (`lang/pt.json` e `lang/esp.json`) traduzidas e revisadas para o Português do Brasil, incluindo menus, combates, diálogos das personagens (Toriel, Chara, Frisk, Sans, Papyrus, Undyne, Alphys, Mettaton, Muffet, etc.), itens e eventos interativos.
2. **Integração Nativa com o Seletor de Idiomas:**
   - Como o executável original do jogo valida os slots listados em `lang/support.json` (`rus.json`, `eng.json`, `esp.json`, `zh.json`), nossa tradução é mantida tanto em `lang/pt.json` (fonte principal) quanto aplicada diretamente sobre `lang/esp.json` (com backup preservado em `lang/esp_original.json`).
   - No menu do jogo, a opção aparece nativamente como **"Português"**.
3. **Atualizador Inteligente para Novas Versões (`scripts/update_and_apply_ptbr.py`):**
   - Quando sair uma atualização nova na página oficial ([adulttale.itch.io/adulttale](https://adulttale.itch.io/adulttale)), basta baixar a nova versão e rodar o script para **reaproveitar 100% de todas as falas já traduzidas** e listar/mesclar apenas as linhas inéditas da atualização!

---

## 🔄 Como Atualizar o Jogo para uma Nova Versão Oficial

Quando você baixar uma versão mais recente do jogo em `C:\Jogos\Adulttale` (ou outra pasta):

1. **Verificar o que mudou na nova versão (quantas linhas novas entraram):**
   ```bash
   python games/nsfw/Adulttale/scripts/update_and_apply_ptbr.py --check --game-dir "C:\Jogos\Adulttale"
   ```
2. **Mesclar a tradução existente com o novo `eng.json` e já aplicar no jogo:**
   ```bash
   python games/nsfw/Adulttale/scripts/update_and_apply_ptbr.py --merge --game-dir "C:\Jogos\Adulttale"
   ```
3. **Apenas reinstalar/aplicar a tradução PT-BR na pasta do jogo:**
   ```bash
   python games/nsfw/Adulttale/scripts/update_and_apply_ptbr.py --apply --game-dir "C:\Jogos\Adulttale"
   ```

---

## 💾 Saves e Configurações (`saves/`)

O Adulttale armazena seus dados de progresso e configurações no Windows em:
```text
%LOCALAPPDATA%\Adulttale\
```
Os arquivos versionados na pasta `saves/` incluem:
- `global_save_0.ini` e `all` (progresso completo e desbloqueios)
- `settings.ini` (configurado com `language="esp"` para iniciar direto em Português)
- `pause_screen.png`
