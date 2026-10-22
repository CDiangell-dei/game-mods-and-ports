# 🗡️ Shadow of the Colossus - Port Nativo para PC (PT-BR)

Port nativo x86-64 do clássico **Shadow of the Colossus** para Windows baseado em recompilação estática (`PS2Recomp`), adaptado para a versão oficial com dublagem e legendas em **Português do Brasil** (`SCUS-974.72`).

---

## ✨ Recursos Exclusivos Desta Versão

* **60 FPS Nativos e Ultra-Widescreen**: Renderização OpenGL 4.6 com aspect ratio adaptativo para monitores modernos (16:9, 21:9, 32:9).
* **Forçamento Automático de GPU Dedicada**: Exporta `NvOptimusEnablement` e `AmdPowerXpressRequestHighPerformance` direto no `.exe` para garantir que notebooks e PCs usem a placa de vídeo dedicada (NVIDIA GeForce / AMD Radeon) e nunca a placa integrada fraca.
* **Controles Modernos de PC**:
  * **WASD**: Movimentação fluida do Wander e navegação completa em todos os menus.
  * **Mouse 360°**: Câmera livre suave sem aceleração artificial.
  * **Roda do Mouse (Scroll Wheel)**: Troca dinâmica de armas (Espada $\leftrightarrow$ Arco).
  * **Mira com o Mouse**: Ao erguer a espada para refletir a luz solar ou ao puxar a corda do arco, a mira acompanha a movimentação do mouse.
* **Quick Save / Quick Load (`F5` / `F9`)**: Sistema instantâneo de salvamento de estados em disco na pasta `states/` sem travar no hardware do memory card do PS2.
* **Inicializador Silencioso**: Script `.vbs` que inicia o jogo diretamente sem nenhuma janela preta do CMD.
* **Otimização de Shaders**: Multi-pass motion blur desativado para imagem limpa e nítida sem perda de quadros.

---

## 🕹️ Controles Principais

| Ação | Teclado / Mouse |
| :--- | :--- |
| **Mover Wander / Navegar nos Menus** | **`W`, `A`, `S`, `D`** |
| **Câmera Livre 360°** | **Movimento do Mouse** |
| **Trocar de Arma (Espada / Arco / Vazio)** | **`Rolar a Rodinha do Mouse`** (ou `Setas`) |
| **Atacar (Espada) / Disparar Flecha (Arco)** | **`Botão Esquerdo do Mouse`** |
| **Focar Luz Solar (Espada) / Agarrar / Montar Agro** | **`Botão Direito do Mouse`** |
| **Mirar Luz Solar e Flecha** | **Movimento do Mouse** (ao segurar Botão Direito ou Esquerdo) |
| **Pular / Montar em Agro** | **`Barra de ESPAÇO`** |
| **Agachar / Segurar firme no pelo dos Colossos** | **`Shift Esquerdo`** |
| **Focar Câmera / Zoom no Colosso** | **`Q`** |
| **Confirmar / Avançar Diálogo** | **`F`** ou **`ENTER`** |
| **Salvar Jogo Imediato (Quick Save)** | **`F5`** |
| **Carregar Jogo Imediato (Quick Load)** | **`F9`** |
| **Exibir Medidor de FPS** | **`F3`** |
| **Alternar Tela Cheia** | **`F11`** |

---

## 📂 Estrutura de Arquivos

```text
Shadow-of-the-Colossus/
├── GUIA_DO_JOGO_E_CONTROLES.txt     # Guia rápido de comandos e dicas em PT-BR
├── README.md                        # Esta documentação completa
├── launchers/                       # Scripts de inicialização e configurações
│   ├── Jogar_Shadow_of_the_Colossus_PTBR (Sem Janela CMD).vbs
│   ├── Jogar_Shadow_of_the_Colossus_PTBR.bat
│   ├── Play.bat
│   └── sotc.ini
├── patches/                         # Perfis e mapa de símbolos para SCUS-974.72
│   ├── SCUS-97472_v1.00.json
│   └── ADDRESS_MAP.generated.csv
├── src/                             # Código-fonte modificado em C++20
│   ├── main.cpp                     # Exports de GPU dedicada e ponto de entrada
│   ├── ps2_host_input.cpp           # Mouse wheel, WASD em menus e mira com mouse
│   ├── display_mode.cpp             # Adaptação widescreen
│   ├── function_hooks.cpp           # Tabela de observadores e hooks
│   ├── config.cpp                   # Carregador de configurações
│   └── hle/                         # Emulação HLE de arquivos e disco
└── build_scripts/
    └── build_windows.bat            # Automação de compilação x64 com MSVC + CMake
```
