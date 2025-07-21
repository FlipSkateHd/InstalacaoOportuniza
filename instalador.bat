@echo off
setlocal enabledelayedexpansion
title Instalador Automatico - Oportuniza

:: Verificar permissões de admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Este script precisa ser executado como ADMINISTRADOR.
    echo [!] Clique com botao direito e selecione "Executar como administrador"
    pause
    exit /b
)

:: Caminhos e configurações
set "SCRIPT_DIR=%~dp0"
set "FOTO=%SCRIPT_DIR%Oportuniza_WinCinza.png"
set "TXT_ORIG=%SCRIPT_DIR%Projeto.txt"
set "TXT_DEST=%USERPROFILE%\Desktop\Projeto.txt"
set "TMP_DIR=%TEMP%\instaladores"
set "ACCOUNT_PICS=%APPDATA%\Microsoft\Windows\AccountPictures"

:: Criar diretórios necessários
mkdir "%TMP_DIR%" >nul 2>&1
mkdir "%ACCOUNT_PICS%" >nul 2>&1

:: Perguntar o nome do PC uma vez
echo ================================
echo    CONFIGURACAO INICIAL
echo ================================
set /p SUFIXO=[?] Digite o sufixo do nome da maquina (ex: 01, SALA3): POS-
set "NOMECOMPLETO=POS-%SUFIXO%"
echo [i] Nome completo sera: %NOMECOMPLETO%
echo.

:MENU
cls
echo ================================
echo      MENU - INSTALADOR v2.0
echo ================================
echo Nome da maquina: %NOMECOMPLETO%
echo ================================
echo 1. Instalar LibreOffice
echo 2. Instalar Google Chrome
echo 3. Renomear o computador
echo 4. Copiar e personalizar Projeto.txt
echo 5. Configurar foto do usuario
echo 6. Executar tudo (modo completo)
echo 7. Verificar instalacoes
echo 0. Sair
echo ================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="1" goto inst_libo
if "%opcao%"=="2" goto inst_chrome
if "%opcao%"=="3" goto renomear_pc
if "%opcao%"=="4" goto projeto
if "%opcao%"=="5" goto foto
if "%opcao%"=="6" goto tudo
if "%opcao%"=="7" goto verificar
if "%opcao%"=="0" exit
echo [!] Opcao invalida!
timeout /t 2 >nul
goto MENU

:inst_libo
echo ================================
echo    INSTALANDO LIBREOFFICE
echo ================================
if exist "%SCRIPT_DIR%LibreOffice_25.2.3_Win_x86-64.msi" (
    echo [+] Instalando LibreOffice...
    echo [i] Aguarde, isso pode levar alguns minutos...
    msiexec /i "%SCRIPT_DIR%LibreOffice_25.2.3_Win_x86-64.msi" /quiet /norestart
    if %errorlevel% equ 0 (
        echo [✓] LibreOffice instalado com sucesso.
    ) else (
        echo [X] Erro durante a instalacao do LibreOffice.
    )
) else (
    echo [X] Arquivo LibreOffice_25.2.3_Win_x86-64.msi nao encontrado.
    echo [i] Verifique se o arquivo esta na mesma pasta do script.
)
echo.
pause
goto MENU

:inst_chrome
echo ================================
echo    INSTALANDO GOOGLE CHROME
echo ================================
echo [+] Baixando Google Chrome...
powershell -Command "try { Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TMP_DIR%\chrome_installer.exe' -UseBasicParsing; exit 0 } catch { exit 1 }" >nul 2>&1
if %errorlevel% equ 0 (
    if exist "%TMP_DIR%\chrome_installer.exe" (
        echo [+] Instalando Google Chrome...
        "%TMP_DIR%\chrome_installer.exe" /silent /install
        timeout /t 10 >nul
        echo [✓] Chrome instalado com sucesso.
        del "%TMP_DIR%\chrome_installer.exe" >nul 2>&1
    ) else (
        echo [X] Falha ao baixar o instalador do Chrome.
    )
) else (
    echo [X] Erro de conexao. Verifique sua internet.
)
echo.
pause
goto MENU

:renomear_pc
echo ================================
echo    RENOMEANDO COMPUTADOR
echo ================================
echo [+] Alterando nome do computador para: %NOMECOMPLETO%
wmic computersystem where name="%COMPUTERNAME%" call rename name="%NOMECOMPLETO%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Nome do computador alterado para %NOMECOMPLETO%.
    echo [!] REINICIE o computador para aplicar a mudanca.
) else (
    echo [X] Erro ao renomear o computador.
)
echo.
pause
goto MENU

:projeto
echo ================================
echo    CONFIGURANDO PROJETO.TXT
echo ================================
if exist "%TXT_ORIG%" (
    echo [+] Copiando Projeto.txt para a area de trabalho...
    copy "%TXT_ORIG%" "%TXT_DEST%" >nul
    if exist "%TXT_DEST%" (
        echo [+] Personalizando conteudo...
        >"%TMP_DIR%\temp.txt" (
            for /f "usebackq delims=" %%L in ("%TXT_DEST%") do (
                set "linha=%%L"
                setlocal enabledelayedexpansion
                set "linha=!linha:Máquina: POS-=Máquina: %NOMECOMPLETO%!"
                set "linha=!linha:Maquina: POS-=Maquina: %NOMECOMPLETO%!"
                echo !linha!
                endlocal
            )
        )
        move /y "%TMP_DIR%\temp.txt" "%TXT_DEST%" >nul
        echo [✓] Projeto.txt criado e personalizado com: %NOMECOMPLETO%
    ) else (
        echo [X] Erro ao copiar Projeto.txt
    )
) else (
    echo [X] Arquivo Projeto.txt nao encontrado na pasta do script.
)
echo.
pause
goto MENU


:foto
echo ================================
echo    CONFIGURANDO FOTO DO USUARIO
echo ================================
if exist "%FOTO%" (
    echo [+] Configurando foto do perfil para Windows 10...
    
    :: Obter SID do usuário atual
    for /f "tokens=2 delims==" %%i in ('wmic useraccount where name^="%USERNAME%" get sid /value ^| find "SID"') do set "USER_SID=%%i"
    echo [i] SID do usuario: %USER_SID%
    
    :: Criar diretórios necessários
    set "PROFILE_IMAGES=%PROGRAMDATA%\Microsoft\User Account Pictures"
    set "TEMP_IMAGES=%LOCALAPPDATA%\Temp\ProfileImages"
    mkdir "%PROFILE_IMAGES%" >nul 2>&1
    mkdir "%TEMP_IMAGES%" >nul 2>&1
    
    :: Método 1: Registro do Windows (mais efetivo para Win10 Home)
    echo [+] Configurando via registro do Windows...
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\%USER_SID%" /v Image32 /t REG_SZ /d "%FOTO%" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\%USER_SID%" /v Image40 /t REG_SZ /d "%FOTO%" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\%USER_SID%" /v Image48 /t REG_SZ /d "%FOTO%" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\%USER_SID%" /v Image96 /t REG_SZ /d "%FOTO%" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\%USER_SID%" /v Image192 /t REG_SZ /d "%FOTO%" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\%USER_SID%" /v Image448 /t REG_SZ /d "%FOTO%" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\%USER_SID%" /v Image1080 /t REG_SZ /d "%FOTO%" /f >nul 2>&1
    
    :: Método 2: PowerShell com redimensionamento automático
    echo [+] Redimensionando e aplicando imagem...
    powershell -Command "
    try {
        Add-Type -AssemblyName System.Drawing
        $originalImage = [System.Drawing.Image]::FromFile('%FOTO%')
        
        # Criar diferentes tamanhos
        $sizes = @(32, 40, 48, 96, 192, 448, 1080)
        foreach ($size in $sizes) {
            $resized = New-Object System.Drawing.Bitmap($size, $size)
            $graphics = [System.Drawing.Graphics]::FromImage($resized)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($originalImage, 0, 0, $size, $size)
            
            $outputPath = '%TEMP_IMAGES%\user-' + $size + '.png'
            $resized.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $graphics.Dispose()
            $resized.Dispose()
        }
        
        $originalImage.Dispose()
        Write-Host 'Imagens redimensionadas com sucesso'
    } catch {
        Write-Host 'Erro ao processar imagem: ' $_.Exception.Message
    }"
    
    :: Método 3: Copiar para locais específicos do Windows 10
    echo [+] Copiando para diretórios do sistema...
    if exist "%TEMP_IMAGES%\user-192.png" (
        copy "%TEMP_IMAGES%\user-32.png" "%PROFILE_IMAGES%\user-32.png" >nul 2>&1
        copy "%TEMP_IMAGES%\user-40.png" "%PROFILE_IMAGES%\user-40.png" >nul 2>&1
        copy "%TEMP_IMAGES%\user-48.png" "%PROFILE_IMAGES%\user-48.png" >nul 2>&1
        copy "%TEMP_IMAGES%\user-96.png" "%PROFILE_IMAGES%\user-96.png" >nul 2>&1
        copy "%TEMP_IMAGES%\user-192.png" "%PROFILE_IMAGES%\user-192.png" >nul 2>&1
    ) else (
        :: Se o redimensionamento falhou, usar imagem original
        copy "%FOTO%" "%PROFILE_IMAGES%\user.png" >nul 2>&1
    )
    
    :: Método 4: AccountPictures do usuário atual
    set "USER_ACCOUNT_PICS=%APPDATA%\Microsoft\Windows\AccountPictures"
    mkdir "%USER_ACCOUNT_PICS%" >nul 2>&1
    copy "%FOTO%" "%USER_ACCOUNT_PICS%\%USERNAME%.png" >nul 2>&1
    copy "%FOTO%" "%USER_ACCOUNT_PICS%\%USERNAME%.accountpicture-ms" >nul 2>&1
    
    :: Método 5: Forçar atualização do cache de imagens
    echo [+] Limpando cache de imagens...
    taskkill /f /im explorer.exe >nul 2>&1
    timeout /t 2 >nul
    start explorer.exe
    
    :: Método 6: Via PowerShell com Set-UserPhoto (se disponível)
    echo [+] Tentando Set-UserPhoto...
    powershell -Command "
    try {
        if (Get-Command Set-UserPhoto -ErrorAction SilentlyContinue) {
            Set-UserPhoto -PicturePath '%FOTO%'
            Write-Host 'Set-UserPhoto executado'
        } else {
            Write-Host 'Set-UserPhoto nao disponivel'
        }
    } catch {
        Write-Host 'Erro no Set-UserPhoto'
    }" 2>nul
    
    echo [✓] Foto configurada com multiplos metodos.
    echo [!] IMPORTANTE para Windows 10 Home:
    echo [!] 1. Faca LOGOFF e LOGIN novamente
    echo [!] 2. Ou va em Configuracoes ^> Contas ^> Suas informacoes
    echo [!] 3. Clique em "Procurar um" e selecione a imagem manualmente
    echo [!] 4. A imagem esta em: %PROFILE_IMAGES%
    
    :: Limpar arquivos temporários
    rmdir /s /q "%TEMP_IMAGES%" >nul 2>&1
    
) else (
    echo [X] Imagem Oportuniza_WinCinza.png nao encontrada.
    echo [i] Verifique se o arquivo esta na mesma pasta do script.
)
echo.
pause
goto MENU


:verificar
echo ================================
echo    VERIFICACAO DE INSTALACOES
echo ================================
echo [+] Verificando programas instalados...
echo.

:: Verificar LibreOffice
if exist "%ProgramFiles%\LibreOffice*" (
    echo [✓] LibreOffice: INSTALADO
) else (
    echo [X] LibreOffice: NAO ENCONTRADO
)

:: Verificar Chrome
if exist "%ProgramFiles%\Google\Chrome*" (
    echo [✓] Google Chrome: INSTALADO
) else if exist "%ProgramFiles(x86)%\Google\Chrome*" (
    echo [✓] Google Chrome: INSTALADO
) else (
    echo [X] Google Chrome: NAO ENCONTRADO
)

:: Verificar nome do PC
echo [i] Nome atual do PC: %COMPUTERNAME%
if "%COMPUTERNAME%"=="%NOMECOMPLETO%" (
    echo [✓] Nome do PC: CORRETO
) else (
    echo [!] Nome do PC: DIFERENTE (pode precisar reiniciar)
)

:: Verificar Projeto.txt
if exist "%TXT_DEST%" (
    echo [✓] Projeto.txt: CRIADO
) else (
    echo [X] Projeto.txt: NAO ENCONTRADO
)

:: Verificar foto
if exist "%ACCOUNT_PICS%\user.png" (
    echo [✓] Foto do usuario: CONFIGURADA
) else (
    echo [X] Foto do usuario: NAO CONFIGURADA
)

echo.
pause
goto MENU

:tudo
echo ================================
echo    EXECUCAO COMPLETA
echo ================================
echo [+] Iniciando instalacao completa...
echo.

call :inst_libo
echo.
call :inst_chrome
echo.
call :renomear_pc
echo.
call :projeto
echo.
call :foto
echo.

echo ================================
echo    INSTALACAO CONCLUIDA
echo ================================
echo [✓] Processo completo finalizado!
echo.
echo [!] IMPORTANTE: Reinicie o computador para aplicar todas as mudancas.
echo [!] Especialmente para o novo nome do computador ter efeito.
echo.
pause
goto MENU
