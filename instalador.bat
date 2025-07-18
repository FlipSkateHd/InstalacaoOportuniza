@echo off
:: Verificar se é administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Este script precisa ser executado como administrador.
    pause
    exit /b
)

:: Obter o caminho da pasta atual (Programas)
set "SCRIPT_DIR=%~dp0"
set "DRIVE_LETRA=%SCRIPT_DIR:~0,2%"

:: Criar pasta temporária
set "TMP_DIR=%TEMP%\instaladores"
mkdir "%TMP_DIR%" >nul 2>&1

echo.
echo [+] Instalando LibreOffice localmente...

:: Instalar LibreOffice local (se existir)
if exist "%SCRIPT_DIR%LibreOffice_25.2.3_Win_x86-64.msi" (
    msiexec /i "%SCRIPT_DIR%LibreOffice_25.2.3_Win_x86-64.msi" /quiet /norestart
    echo [✓] LibreOffice instalado com sucesso.
) else (
    echo [X] Arquivo LibreOffice_25.2.3_Win_x86-64.msi não encontrado.
)

echo.
echo [+] Baixando e instalando Google Chrome...

:: Baixar Chrome
powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TMP_DIR%\chrome_installer.exe'"
if exist "%TMP_DIR%\chrome_installer.exe" (
    "%TMP_DIR%\chrome_installer.exe" /silent /install
    echo [✓] Chrome instalado com sucesso.
) else (
    echo [X] Falha ao baixar o Chrome.
)

echo.
:: Solicitar parte final do nome da máquina
set /p SUFIXO=[?] Digite o sufixo do nome da máquina (ex: 01, SALA3): POS-
set "NOMECOMPLETO=POS-%SUFIXO%"

:: Renomear a máquina
wmic computersystem where name="%COMPUTERNAME%" call rename name="%NOMECOMPLETO%"
echo [✓] Nome do computador alterado para: %NOMECOMPLETO%
echo (a mudança só terá efeito após reiniciar o sistema)

echo.
echo [+] Copiando e atualizando Projeto.txt...

:: Copiar arquivo Projeto.txt para a Área de Trabalho e editar a linha "Máquina: POS-"
if exist "%SCRIPT_DIR%Projeto.txt" (
    copy "%SCRIPT_DIR%Projeto.txt" "%USERPROFILE%\Desktop\Projeto.txt" >nul
    powershell -Command ^
        "(Get-Content '%USERPROFILE%\Desktop\Projeto.txt') | ForEach-Object { $_ -replace '^Máquina: POS-.*', 'Máquina: %NOMECOMPLETO%' } | Set-Content -Encoding UTF8 '%USERPROFILE%\Desktop\Projeto.txt'"
    echo [✓] Projeto.txt copiado e atualizado com o nome da máquina: %NOMECOMPLETO%.
) else (
    echo [X] Arquivo Projeto.txt não encontrado.
)

echo.
echo [✓] Tudo pronto! Reinicie o computador para aplicar as mudanças.
pause
exit

