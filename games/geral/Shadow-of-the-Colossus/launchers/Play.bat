@echo off
setlocal
cd /d "%~dp0"
if not exist "sotc.exe" (
    echo sotc.exe is missing. Extract the entire release ZIP before playing.
    pause
    exit /b 1
)
echo ========================================================
echo   Shadow of the Colossus - Port Nativo para PC (PT-BR)
echo ========================================================
echo   Versao SCUS-97472 traduzida em Portugues
echo.
echo Controles Principais:
echo   - W, A, S, D   : Movimento / Navegacao nos Menus
echo   - SETAS        : Navegacao nos Menus / Selecao
echo   - RODA MOUSE   : Trocar de Arma (Espada / Arco)
echo   - MOUSE MIRA   : Mirar Espada e Arco
echo   - ENTER / F    : Start / Confirmar (X)
echo   - ESPACO       : Triangulo (Pular / Montar)
echo   - CLIQUE ESQ   : Quadrado (Atacar com Espada / Arco)
echo   - CLIQUE DIR   : Circulo (Agarrar / Chamar Agro)
echo   - SHIFT ESQ    : Agachar / Segurar firme no Colosso
echo   - F5           : SALVAR JOGO (Save State rapido)
echo   - F9           : CARREGAR JOGO (Load State rapido)
echo   - F3           : Mostrar/Ocultar medidor de FPS
echo   - F11          : Alternar Tela Cheia
echo.
echo * Dica: Se quiser abrir o jogo sem esta janela preta,
echo   basta dar dois cliques em "Jogar (Sem Janela CMD).vbs".
echo.
"%~dp0sotc.exe" %*
set "GAME_EXIT=%ERRORLEVEL%"
if "%GAME_EXIT%"=="0" exit /b 0
echo.
echo O jogo encerrou com codigo %GAME_EXIT%.
pause
exit /b %GAME_EXIT%
