
@echo off
setlocal enabledelayedexpansion

:: Verificar permissões de admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Execute este script como ADMINISTRADOR.
    pause
    exit /b
)

:: Caminhos
set "SCRIPT_DIR=%~dp0"
set "FOTO=%SCRIPT_DIR%Oportuniza_WinCinza.png"
set "TXT_ORIG=%SCRIPT_DIR%Projeto.txt"
set "TXT_DEST=%USERPROFILE%\Desktop\Projeto.txt"
set "TMP_DIR=%TEMP%\instaladores"
mkdir "%TMP_DIR%" >nul 2>&1

:: Perguntar o nome do PC uma vez
set /p SUFIXO=[?] Digite o sufixo do nome da máquina (ex: 01, SALA3): POS-
set "NOMECOMPLETO=POS-%SUFIXO%"

:MENU
cls
echo ================================
echo      MENU - INSTALADOR
echo ================================
echo 1. Instalar LibreOffice
echo 2. Instalar Google Chrome
echo 3. Renomear o computador
echo 4. Copiar e personalizar Projeto.txt
echo 5. Trocar foto do usuário
echo 6. Executar tudo (modo completo)
echo 0. Sair
echo ================================
set /p opcao=Escolha uma opcao:

if "%opcao%"=="1" goto inst_libo
if "%opcao%"=="2" goto inst_chrome
if "%opcao%"=="3" goto renomear_pc
if "%opcao%"=="4" goto projeto
if "%opcao%"=="5" goto foto
if "%opcao%"=="6" goto tudo
if "%opcao%"=="0" exit
goto MENU

:inst_libo
if exist "%SCRIPT_DIR%LibreOffice_25.2.3_Win_x86-64.msi" (
    echo [+] Instalando LibreOffice...
    msiexec /i "%SCRIPT_DIR%LibreOffice_25.2.3_Win_x86-64.msi" /quiet /norestart
    echo [✓] LibreOffice instalado.
) else (
    echo [X] Arquivo do LibreOffice não encontrado.
)
pause
goto MENU

:inst_chrome
echo [+] Baixando Google Chrome...
powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TMP_DIR%\chrome_installer.exe'" >nul
if exist "%TMP_DIR%\chrome_installer.exe" (
    "%TMP_DIR%\chrome_installer.exe" /silent /install
    echo [✓] Chrome instalado.
) else (
    echo [X] Falha ao baixar Chrome.
)
pause
goto MENU

:renomear_pc
wmic computersystem where name="%COMPUTERNAME%" call rename name="%NOMECOMPLETO%"
echo [✓] Nome do computador alterado para %NOMECOMPLETO%.
pause
goto MENU

:projeto
if exist "%TXT_ORIG%" (
    copy "%TXT_ORIG%" "%TXT_DEST%" >nul

    >"%TMP_DIR%\temp.txt" (
        for /f "usebackq delims=" %%L in ("%TXT_DEST%") do (
            set "linha=%%L"
            setlocal enabledelayedexpansion
            echo !linha:Máquina: POS-=Máquina: %NOMECOMPLETO%! 
            endlocal
        )
    )
    move /y "%TMP_DIR%\temp.txt" "%TXT_DEST%" >nul
    echo [✓] Projeto.txt atualizado com o nome da máquina: %NOMECOMPLETO%.
) else (
    echo [X] Projeto.txt não encontrado.
)
pause
goto MENU

:foto
if exist "%FOTO%" (
    copy "%FOTO%" "%APPDATA%\Microsoft\Windows\AccountPictures\foto.png" >nul
    echo [✓] Foto copiada para o perfil do usuário.
) else (
    echo [X] Imagem Oportuniza_WinCinza.png não encontrada.
)
pause
goto MENU

:tudo
call :inst_libo
call :inst_chrome
call :renomear_pc
call :projeto
call :foto
echo.
echo [✓] Tudo concluído! Reinicie o computador para aplicar as mudanças.
pause
goto MENU
