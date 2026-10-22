@echo off
setlocal
echo ========================================================
echo   Shadow of the Colossus PC (PT-BR) - Build Automation
echo ========================================================
echo.

set "VS_VCVARS=C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%VS_VCVARS%" (
    set "VS_VCVARS=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
)

if not exist "%VS_VCVARS%" (
    echo [ERRO] vcvars64.bat nao encontrado. Instale o Visual Studio C++ Build Tools.
    pause
    exit /b 1
)

echo [1/3] Carregando ambiente MSVC x64...
call "%VS_VCVARS%" >nul

echo [2/3] Compilando executavel sotc.exe...
set "CMAKE_BIN=C:\Users\cield\AppData\Local\Microsoft\WinGet\Packages\Kitware.CMake_Microsoft.Winget.Source_8wekyb3d8bbwe\cmake-4.4.4-windows-x86_64\bin\cmake.exe"
if not exist "%CMAKE_BIN%" set "CMAKE_BIN=cmake"

"%CMAKE_BIN%" --build "C:\Jogos\Shadow of the Colossus\sotc-port\build\port" --target sotc
if %ERRORLEVEL% neq 0 (
    echo [ERRO] Falha na compilacao.
    pause
    exit /b %ERRORLEVEL%
)

echo [3/3] Copiando sotc.exe para o pacote de release...
copy /y "C:\Jogos\Shadow of the Colossus\sotc-port\build\port\bin\sotc.exe" "C:\Jogos\Shadow of the Colossus\SOTC_PC_PTBR\sotc-v1.0.0-ptbr-windows-x64\sotc.exe"

echo.
echo ========================================================
echo   Compilacao concluida com sucesso!
echo ========================================================
pause
exit /b 0
