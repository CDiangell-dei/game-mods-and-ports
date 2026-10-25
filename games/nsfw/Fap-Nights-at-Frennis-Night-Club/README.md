# 🍕 Fap Nights at Frenni's Night Club — Tradução Completa PT-BR & Patcher

Localização completa para o Português do Brasil (PT-BR), ferramentas de atualização contínua e executáveis oficiais para **Fap Nights at Frenni's Night Club** (desenvolvido por **Fatal Fire Studios** com modelos por **Cryptia Curves**).

---

## 🔗 Links Oficiais do Jogo

- **Página Oficial (Itch.io):** [https://fatal-fire-studios.itch.io/fap-nights-at-frennis-night-club](https://fatal-fire-studios.itch.io/fap-nights-at-frennis-night-club)
- **Desenvolvedor:** Fatal Fire Studios
- **Versões Base Integradas:**
  - **Story Mode (Modo História):** `v0.2.2 FIX2`
  - **Arcade Mode (Modo Arcade):** `v0.2.8xxx♥`
- **Pasta Local de Instalação (Padrão):** `C:\Jogos\Fap-Nights-at-Frennis-Night-Club\`
  - `Story-Mode/` (Executável: `FAP NIGHTS AT FRENNIs.exe`)
  - `Arcade-Mode/` (Executável: `FAP N.A.F. ARCADE MODE.exe`)
- **Pasta de Saves e Progresso (Windows):** `%USERPROFILE%\AppData\LocalLow\Fatal Fire Studios\Fap Nights At Frennis Night Club\`

---

## 📁 Estrutura no Repositório

```
Fap-Nights-at-Frennis-Night-Club/
├── FAP NIGHTS AT FRENNIs.exe           # Executável oficial do Story Mode (v0.2.2)
├── FAP N.A.F. ARCADE MODE.exe          # Executável oficial do Arcade Mode (v0.2.8)
├── lang/
│   ├── pt_br.json                     # Dicionário universal PT-BR (6.093 chaves traduzidas)
│   ├── story_strings.json             # Dump e mapeamento estruturado de cenas do Story Mode
│   └── arcade_strings.json            # Dump e mapeamento estruturado de cenas do Arcade Mode
├── scripts/
│   └── update_and_apply_ptbr.py        # Patcher e atualizador automatizado (UnityPy / REA)
└── README.md
```

---

## 🛠️ Arquitetura Técnica, Engenharia Reversa (REA) & Seletor PT-BR

A análise arquitetural e extração profunda dos binários foram realizadas com o **REA (Reverse Engineer Anything)** e o framework **UnityPy**:

1. **Arquitetura Dual-Slot & Opção "PORTUGUÊS (PT-BR)" no Menu:**
   - O jogo possui internamente uma estrutura paralela de GameObjects para cada idioma (ex.: `... INGLES` ativo quando `IDIOMA == 1`, e `... ESPAÑOL` ativo quando `IDIOMA == 0`).
   - O seletor de idiomas original continha apenas botões para inglês e espanhol.
   - **Solução Implementada (Função PT-BR Nativa):**
     - O botão de idioma primário foi renomeado e configurado para **`PORTUGUÊS (PT-BR)`**.
     - O botão secundário foi configurado para **`PORTUGUÊS`**.
     - O título do menu foi ajustado para **`IDIOMA: PORTUGUÊS`**.
     - **Ambos os slots (inglês e espanhol) foram 100% traduzidos para o Português Brasileiro.**
     - Desta forma, mesmo se o jogador alternar acidentalmente de opção de idioma nas configurações, **o jogo nunca perde a tradução**, garantindo 100% de estabilidade e consistência visual.

2. **Story Mode (`v0.2.2 FIX2`):**
   - Engine: **Unity (Mono BleedingEdge x64)**
   - Código de script gerenciado em `Assembly-CSharp.dll` com controle de idioma via `PlayerPrefs` e GameObjects dinâmicos (`IDIOMACONTROL`).
   - Os textos da interface, diálogos, chamadas telefônicas e missões ficam serializados em componentes `MonoBehaviour` do tipo `UnityEngine.UI.Text` (`m_Script` PathID `434`).
   - A string `m_Text` fica localizada no byte relativo **128** da estrutura binária de cada objeto serializado nas cenas (`level0` a `level31` e `sharedassets*.assets`).
   - **8.467 componentes de texto localizados.**

3. **Arcade Mode (`v0.2.8xxx♥`):**
   - Engine: **Unity (IL2CPP x64)**
   - Código nativo compilado em `GameAssembly.dll` com metadados estruturados em `global-metadata.dat`.
   - Utiliza versão mais recente da pipeline gráfica do Unity, onde o componente `UnityEngine.UI.Text` (`m_Script` PathID `475`) posiciona a string `m_Text` no byte relativo **144**.
   - **1.844 componentes de texto localizados.**

4. **Injeção de Tradução Segura & Preservação de Formatação:**
   - O utilitário `update_and_apply_ptbr.py` conta com resolução inteligente de espaços em branco, quebras de linha (`\r`, `\n`) e recuos de diálogos, preservando a diagramação original dos textos nas caixas de fala.
   - Mais de **10.311 componentes de texto** foram traduzidos e validados nos arquivos de cenas locais.

---

## 🚀 Como Aplicar ou Atualizar a Tradução

### 1. Verificar o Status da Instalação
```powershell
python games/nsfw/Fap-Nights-at-Frennis-Night-Club/scripts/update_and_apply_ptbr.py --check
```

### 2. Aplicar a Tradução PT-BR nos Jogos Instalados
Para aplicar em `C:\Jogos\Fap-Nights-at-Frennis-Night-Club`:
```powershell
python games/nsfw/Fap-Nights-at-Frennis-Night-Club/scripts/update_and_apply_ptbr.py --apply
```

Se o jogo estiver em outro diretório:
```powershell
python games/nsfw/Fap-Nights-at-Frennis-Night-Club/scripts/update_and_apply_ptbr.py --game-dir "D:\MeusJogos\Frenni" --apply
```

### 3. Atualizar para uma Nova Versão Oficial
Quando sair uma nova versão na página oficial do Itch.io:
1. Baixe e extraia a nova versão na pasta do jogo.
2. Execute o verificador e mesclador para incorporar novos textos em `lang/pt_br.json`:
   ```powershell
   python games/nsfw/Fap-Nights-at-Frennis-Night-Club/scripts/update_and_apply_ptbr.py --merge
   ```
3. Reaplique a tradução nos novos arquivos com `--apply`.
