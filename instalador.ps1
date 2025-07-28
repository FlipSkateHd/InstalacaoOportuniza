# Instalador Automatizado com Tratamento de Erros
# Compatível com Windows 10/11 22H2 Pro e Home
$ErrorActionPreference = 'Stop'

Function Tratar-Erro {
    param ([string]$mensagem)
    Write-Host "[X] ERRO: $mensagem" -ForegroundColor Red
    Pause
}

# Requer permissão de administrador
Try {
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(` 
        [Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Throw "Este script precisa ser executado como ADMINISTRADOR."
    }
} Catch {
    Tratar-Erro $_
    Exit
}

Try {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $foto = Join-Path $scriptDir "Oportuniza_WinCinza.png"
    $txtOrig = Join-Path $scriptDir "Projeto.txt"
    $txtDest = Join-Path $env:USERPROFILE "Desktop\Projeto.txt"
    $tmpDir = Join-Path $env:TEMP "instaladores"
    $accountPics = Join-Path $env:APPDATA "Microsoft\Windows\AccountPictures"
    
    New-Item -ItemType Directory -Force -Path $tmpDir, $accountPics | Out-Null
    
    Write-Host "=============================="
    Write-Host "   CONFIGURACAO INICIAL"
    Write-Host "=============================="
    
    $sufixo = Read-Host "[?] Digite o sufixo do nome da maquina (ex: 01, SALA3)"
    $nomeCompleto = "POS-$sufixo"
    Write-Host "[i] Nome completo sera: $nomeCompleto"
    Pause
} Catch {
    Tratar-Erro $_
    Exit
}

Function Menu {
    Clear-Host
    Write-Host "=============================="
    Write-Host "    MENU - INSTALADOR PS1"
    Write-Host "=============================="
    Write-Host "Nome da maquina: $nomeCompleto"
    Write-Host "=============================="
    Write-Host "1. Instalar LibreOffice"
    Write-Host "2. Instalar Google Chrome"
    Write-Host "3. Renomear o computador"
    Write-Host "4. Copiar e personalizar Projeto.txt"
    Write-Host "5. Configurar foto do usuario"
    Write-Host "6. Executar tudo"
    Write-Host "7. Verificar instalacoes"
    Write-Host "0. Sair"
    Write-Host "=============================="
    
    $opcao = Read-Host "Escolha uma opcao"
    
    Switch ($opcao) {
        "1" { Instalar-LibreOffice }
        "2" { Instalar-Chrome }
        "3" { Renomear-PC }
        "4" { Configurar-TXT }
        "5" { Configurar-Foto }
        "6" { Executar-Tudo }
        "7" { Verificar }
        "0" { Exit }
        Default { 
            Write-Host "[!] Opcao invalida!" -ForegroundColor Red
            Start-Sleep 2
        }
    }
    Menu
}

Function Instalar-LibreOffice {
    Try {
        Write-Host "`n[+] Instalando LibreOffice..."
        $installer = Join-Path $scriptDir "LibreOffice_25.2.3_Win_x86-64.msi"
        If (-Not (Test-Path $installer)) {
            Throw "Arquivo do LibreOffice nao encontrado."
        }
        Start-Process msiexec.exe -ArgumentList "/i `"$installer`" /quiet /norestart" -Wait
        Write-Host "[✓] LibreOffice instalado com sucesso." -ForegroundColor Green
    } Catch {
        Tratar-Erro $_
    }
    Pause
}

Function Instalar-Chrome {
    Try {
        Write-Host "`n[+] Instalando Google Chrome..."
        $chromeInstaller = Join-Path $tmpDir "chrome_installer.exe"
        Invoke-WebRequest "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $chromeInstaller -UseBasicParsing
        Start-Process $chromeInstaller -ArgumentList "/silent /install" -Wait
        Write-Host "[✓] Chrome instalado com sucesso." -ForegroundColor Green
        Remove-Item $chromeInstaller -Force
    } Catch {
        Tratar-Erro "Erro ao instalar Chrome: $_"
    }
    Pause
}

Function Renomear-PC {
    Try {
        Write-Host "`n[+] Renomeando computador para $nomeCompleto"
        Rename-Computer -NewName $nomeCompleto -Force
        Write-Host "[!] Reinicie o computador para aplicar a mudança." -ForegroundColor Yellow
    } Catch {
        Tratar-Erro $_
    }
    Pause
}

Function Configurar-TXT {
    Try {
        Write-Host "`n[+] Configurando Projeto.txt..."
        If (-Not (Test-Path $txtOrig)) { Throw "Projeto.txt nao encontrado." }
        Copy-Item $txtOrig $txtDest -Force
        (Get-Content $txtDest) | ForEach-Object {
            $_ -replace "M[áa]quina: POS-", "Maquina: $nomeCompleto"
        } | Set-Content $txtDest
        Write-Host "[✓] Projeto.txt personalizado." -ForegroundColor Green
    } Catch {
        Tratar-Erro $_
    }
    Pause
}

Function Configurar-Foto {
    try {
        Write-Host "`n[+] Configurando foto do usuário..." -ForegroundColor Cyan
        
        # Usar a variável global $scriptDir que já foi definida no início
        $imgOriginal = Join-Path $scriptDir "Oportuniza_WinCinza.png"
        
        if (-not (Test-Path $imgOriginal)) {
            throw "Imagem não encontrada: $imgOriginal"
        }
        
        # Obter informações do usuário atual
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $sid = $currentUser.User.Value
        
        Write-Host "[i] Configurando para usuário: $env:USERNAME" -ForegroundColor Gray
        
        # Criar diretórios necessários
        $accountPicturesPath = "$env:APPDATA\Microsoft\Windows\AccountPictures"
        $userAccountPicturePath = "$accountPicturesPath\$sid"
        
        New-Item -ItemType Directory -Path $accountPicturesPath -Force | Out-Null
        New-Item -ItemType Directory -Path $userAccountPicturePath -Force | Out-Null
        
        # Carregar assemblies necessários
        Add-Type -AssemblyName System.Drawing
        
        # Carregar a imagem original
        $originalImage = [System.Drawing.Image]::FromFile($imgOriginal)
        
        # Tamanhos necessários para o Windows 10
        $tamanhos = @(448, 192, 96, 64, 48, 40, 32)
        
        Write-Host "[i] Criando imagens redimensionadas..." -ForegroundColor Gray
        
        # Criar as imagens redimensionadas
        foreach ($size in $tamanhos) {
            $resizedBitmap = New-Object System.Drawing.Bitmap($size, $size)
            $graphics = [System.Drawing.Graphics]::FromImage($resizedBitmap)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($originalImage, 0, 0, $size, $size)
            
            $outputPath = Join-Path $userAccountPicturePath "Image$size.jpg"
            $resizedBitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            
            $graphics.Dispose()
            $resizedBitmap.Dispose()
            
            Write-Host "  [✓] Image$size.jpg criada" -ForegroundColor Green
        }
        
        $originalImage.Dispose()
        
        Write-Host "[i] Configurando registro do Windows..." -ForegroundColor Gray
        
        # Configurar registro do Windows
        $registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\$sid"
        
        if (-not (Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force | Out-Null
        }
        
        foreach ($size in $tamanhos) {
            $imagePath = Join-Path $userAccountPicturePath "Image$size.jpg"
            Set-ItemProperty -Path $registryPath -Name "Image$size" -Value $imagePath -Type String
        }
        
        Write-Host "`n[✓] Foto configurada com sucesso!" -ForegroundColor Green
        Write-Host "[!] IMPORTANTE: Faça LOGOFF e LOGIN novamente para ver a mudança" -ForegroundColor Yellow
        Write-Host "[!] A foto pode levar alguns minutos para aparecer" -ForegroundColor Yellow
        
        $resp = Read-Host "`nDeseja fazer logoff agora para aplicar a mudança? (S/N)"
        if ($resp -match '^[sS]') {
            Write-Host "[i] Fazendo logoff em 3 segundos..." -ForegroundColor Yellow
            Start-Sleep -Seconds 3
            shutdown /l
        }
        
    } catch {
        Write-Host "`n[X] Erro ao configurar a foto: $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause
}

Function Verificar {
    Write-Host "`n============================"
    Write-Host "   VERIFICANDO INSTALACOES"
    Write-Host "============================"

    Try {
        If (Test-Path "$env:ProgramFiles\LibreOffice") {
            Write-Host "[✓] LibreOffice: INSTALADO" -ForegroundColor Green
        } Else {
            Write-Host "[X] LibreOffice: NAO ENCONTRADO" -ForegroundColor Red
        }

        If ((Test-Path "$env:ProgramFiles\Google\Chrome") -or (Test-Path "$env:ProgramFiles(x86)\Google\Chrome")) {
            Write-Host "[✓] Google Chrome: INSTALADO" -ForegroundColor Green
        } Else {
            Write-Host "[X] Google Chrome: NAO ENCONTRADO" -ForegroundColor Red
        }

        Write-Host "[i] Nome atual do PC: $env:COMPUTERNAME"
        If ($env:COMPUTERNAME -eq $nomeCompleto) {
            Write-Host "[✓] Nome do PC: CORRETO" -ForegroundColor Green
        } Else {
            Write-Host "[!] Nome do PC: DIFERENTE" -ForegroundColor Yellow
        }

        If (Test-Path $txtDest) {
            Write-Host "[✓] Projeto.txt: PRESENTE" -ForegroundColor Green
        } Else {
            Write-Host "[X] Projeto.txt: NAO ENCONTRADO" -ForegroundColor Red
        }

        # Verificar foto do usuário
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $sid = $currentUser.User.Value
        $userAccountPicturePath = "$env:APPDATA\Microsoft\Windows\AccountPictures\$sid"
        
        If (Test-Path "$userAccountPicturePath\Image192.jpg") {
            Write-Host "[✓] Foto: CONFIGURADA" -ForegroundColor Green
        } Else {
            Write-Host "[X] Foto: NAO CONFIGURADA" -ForegroundColor Red
        }
    } Catch {
        Tratar-Erro $_
    }
    Pause
}

Function Executar-Tudo {
    Instalar-LibreOffice
    Instalar-Chrome
    Renomear-PC
    Configurar-TXT
    Configurar-Foto
    Write-Host "[✓] INSTALACAO COMPLETA CONCLUIDA!" -ForegroundColor Green
    Pause
}

# Iniciar menu
Menu
