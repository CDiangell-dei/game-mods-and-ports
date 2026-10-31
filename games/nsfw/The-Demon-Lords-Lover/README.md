# 👑 The Demon Lord's Lover — Tradução Completa PT-BR (PC & Android)

Tradução integral em Português do Brasil (PT-BR) de **The Demon Lord's Lover** (`v0.18.54`), com suporte nativo tanto para a versão de **Windows (PC)** quanto para a versão **Android (APK)** reempacotada e devidamente assinada com **Android Signature Scheme v2**.

---

## 🔗 Links Oficiais

* 🌐 **Página Oficial no Itch.io:** [The Demon Lord's Lover by ayumu98](https://ayumu98.itch.io/the-demon-lords-lover)
* 📱 **Releases do Repositório (Download Direto):** [GitHub Releases](https://github.com/CDiangell-dei/game-mods-and-ports/releases)

---

## 🕹️ Funcionalidades & Engenharia Reversa (REA)

- **Inspeção de Binários Gerenciados (`Game.dll` & `App.dll`)**:
  - A arquitetura interna de localização foi mapeada via CIL/Mono disassembly:
    - `Game.Localization.TranslationRegistry`: Registro dinâmico de traduções em `StreamingAssets/Localization/<code-ou-source>` e no armazenamento persistente do usuário.
    - `Game.Localization.FontRegistry`: O jogo já incluía mapeamento interno e suporte às fontes (`DepartureMono-Regular` e `NotoSans-Regular SDF`) com caracteres acentuados Latin-1 (`á`, `é`, `í`, `ó`, `ú`, `ã`, `õ`, `ç`, `ê`, etc.).
- **Conteúdo 100% Traduzido**:
  - **`grammar.json`**: Todos os 384 substantivos adaptados com concordância de gênero e número (artigos definidos, indefinidos e plurais), além dos sistemas de pronomes (ele/ela/elu).
  - **`strings.json`**: 2.168 strings de interface, habilidades, itens, menus e combate, com **0 divergências** nas variáveis de formatação (`{heroname}`, `{damage}`, `{actor|definite}`, etc.).
  - **`scenes/`**: 649 arquivos de cena (.scene) em 25 pastas contendo 5.788 falas e eventos narrativos integralmente traduzidos.
- **Port Android Seguro**:
  - Reempacotamento limpo injetando o pacote em `assets/Localization/source/` e `assets/Localization/pt/`.
  - Assinatura digital via **APK Signature Scheme v2** (bloco de assinatura com digests de 1 MB, chave RSA de 2048 bits e certificado X.509 auto-consistente).

---

## 📲 Como Instalar e Jogar

### No Celular / Tablet (Android)
1. Acesse a aba **[Releases](https://github.com/CDiangell-dei/game-mods-and-ports/releases)** deste repositório no seu dispositivo móvel.
2. Baixe o arquivo `the-demon-lords-lover-0.18.54-android-ptbr.apk`.
3. Abra o arquivo baixado e instale normalmente.
4. O jogo iniciará diretamente em Português Brasileiro!

### No Computador (Windows)
Se você já possui o jogo instalado:
1. Baixe o pacote `The_Demon_Lords_Lover_PTBR_Windows_Pack.zip` nas [Releases](https://github.com/CDiangell-dei/game-mods-and-ports/releases) (ou copie o conteúdo da pasta `lang/` deste repositório).
2. Extraia a pasta `pt` para dentro de:
   ```text
   <Pasta_Do_Jogo>\the-demon-lords-lover-0.18.54-win_Data\StreamingAssets\Localization\pt\
   ```
3. No jogo, acesse as **Opções / Settings**, mude o idioma para **Português Brasileiro** e confirme. (Ou substitua o conteúdo da pasta `source` para torná-lo o padrão).

---

## 📂 Estrutura desta Pasta

```text
The-Demon-Lords-Lover/
├── README.md                      # Esta documentação
├── lang/                          # Arquivos da Tradução PT-BR
│   ├── manifest.json              # Manifesto oficial do pacote ("pt")
│   ├── strings.json               # 2.168 termos traduzidos
│   ├── grammar.json               # Dicionário léxico e gramatical PT-BR
│   └── scenes/                    # 649 arquivos .scene traduzidos
└── scripts/                       # Ferramentas utilizadas
    ├── apk_v2_signer.py           # Assinador puro Python para Android APK Scheme v2
    ├── install_pack_tools.py      # Automação de injeção em APK e Windows Data
    └── verify_strings.py          # Verificador de integridade de tags e variáveis
```
