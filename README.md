# Instalador Automatizado - Windows 10/11 22H2

Este script PowerShell automatiza a instalação e configuração de softwares essenciais em computadores Windows 10/11 22H2 Pro e Home.

## 📋 Funcionalidades

- **Instalação do LibreOffice** - Suite de escritório gratuita
- **Instalação do Google Chrome** - Navegador web
- **Renomeação do computador** - Define nome padrão "POS-[sufixo]"
- **Configuração de arquivo Projeto.txt** - Copia e personaliza arquivo de projeto
- **Configuração de foto do usuário** - Define imagem de perfil personalizada
- **Verificação de instalações** - Valida se tudo foi instalado corretamente

## 📁 Estrutura de Arquivos Necessária

```
pasta_do_instalador/
├── instalador.ps1                    # Script principal
├── LibreOffice_25.2.3_Win_x86-64.msi # Instalador do LibreOffice
├── Oportuniza_WinCinza.png           # Imagem para foto do usuário
└── Projeto.txt                       # Arquivo de projeto modelo
```

## 🚀 Como Usar

1. **Execute como Administrador**
   - Clique com botão direito no PowerShell
   - Selecione "Executar como administrador"

2. **Execute o script**
   ```powershell
   .\instalador.ps1
   ```

3. **Digite o sufixo da máquina** quando solicitado
   - Exemplo: "01", "SALA3", "LAB1"
   - O nome final será: "POS-[seu_sufixo]"

4. **Escolha as opções do menu**
   - Opção 6: Executa tudo automaticamente
   - Opções individuais: 1-5 para instalações específicas

## ⚠️ Resolução de Problemas

### Erro: "Não é possível associar o argumento ao parâmetro 'Path' porque ele é nulo"

**Causa:** Arquivo de imagem não encontrado ou caminho inválido.

**Solução:**
1. Verifique se o arquivo `Oportuniza_WinCinza.png` está na mesma pasta do script
2. Certifique-se que o nome do arquivo está correto (sem espaços extras)
3. Verifique se a imagem não está corrompida

```powershell
# Para verificar se o arquivo existe:
Test-Path ".\Oportuniza_WinCinza.png"
# Deve retornar: True
```

### Erro: "Este script precisa ser executado como ADMINISTRADOR"

**Causa:** Script não foi executado com privilégios administrativos.

**Solução:**
1. Feche o PowerShell atual
2. Clique com botão direito no PowerShell
3. Selecione "Executar como administrador"
4. Execute o script novamente

### Erro: "Arquivo do LibreOffice nao encontrado"

**Causa:** Instalador do LibreOffice não está presente.

**Solução:**
1. Baixe o LibreOffice 25.2.3 x64 MSI
2. Renomeie para: `LibreOffice_25.2.3_Win_x86-64.msi`
3. Coloque na mesma pasta do script

### Erro: "Projeto.txt nao encontrado"

**Causa:** Arquivo modelo não está presente.

**Solução:**
1. Crie o arquivo `Projeto.txt` na pasta do script
2. Adicione o conteúdo desejado
3. Inclua a linha: `Máquina: POS-` (será substituída automaticamente)

### Erro na instalação do Chrome

**Causa:** Problemas de conectividade ou bloqueio de firewall.

**Solução:**
1. Verifique a conexão com a internet
2. Temporariamente desative o firewall/antivírus
3. Execute o script novamente
4. Se persistir, baixe manualmente o Chrome

### Erro: "A política de execução não permite..."

**Causa:** Política de execução do PowerShell muito restritiva.

**Solução:**
```powershell
# Execute como administrador:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Foto do usuário não aparece após configuração

**Causa:** Windows precisa atualizar o cache de imagens.

**Solução:**
1. **SEMPRE** faça logoff e login após configurar a foto
2. Aguarde alguns minutos para o Windows processar
3. Se não aparecer, reinicie o computador
4. Verifique se os arquivos foram criados:
   ```powershell
   ls "$env:APPDATA\Microsoft\Windows\AccountPictures"
   ```

### Erro: "Rename-Computer: Acesso negado"

**Causa:** Computador pode estar em domínio ou política de grupo ativa.

**Solução:**
1. Verifique se está executando como administrador
2. Se estiver em domínio, renomeie manualmente:
   - Painel de Controle > Sistema > Alterar configurações
3. Ou use o comando: `netdom renamecomputer`

## 🔧 Configurações Avançadas

### Alterando o nome padrão das máquinas

Edite a linha 27 no script:
```powershell
$nomeCompleto = "POS-$sufixo"  # Altere "POS" para seu prefixo desejado
```

### Adicionando novo software

1. Crie uma nova função seguindo o padrão:
```powershell
Function Instalar-NovoSoftware {
    Try {
        Write-Host "`n[+] Instalando Novo Software..."
        # Código de instalação aqui
        Write-Host "[✓] Software instalado com sucesso." -ForegroundColor Green
    } Catch {
        Tratar-Erro $_
    }
    Pause
}
```

2. Adicione ao menu na função `Menu`
3. Adicione à verificação na função `Verificar`

### Personalizando a imagem do usuário

1. Substitua `Oportuniza_WinCinza.png` por sua imagem
2. Formatos suportados: PNG, JPG, BMP
3. Tamanho recomendado: 448x448 pixels ou maior
4. A imagem será redimensionada automaticamente

## 📊 Logs e Diagnóstico

### Verificando instalações

Use a opção 7 do menu para verificar:
- ✅ LibreOffice instalado
- ✅ Chrome instalado  
- ✅ Nome do PC correto
- ✅ Arquivo Projeto.txt presente
- ✅ Foto configurada

### Locais importantes

- **Foto do usuário:** `%APPDATA%\Microsoft\Windows\AccountPictures\[SID]\`
- **Projeto.txt:** `%USERPROFILE%\Desktop\Projeto.txt`
- **Temp downloads:** `%TEMP%\instaladores\`
- **Registro da foto:** `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\[SID]`

## 🛡️ Segurança

- Script valida permissões de administrador
- Downloads são feitos apenas de fontes oficiais
- Arquivos temporários são limpos automaticamente
- Não armazena senhas ou dados sensíveis

## 🔄 Compatibilidade

- ✅ Windows 10 22H2 Pro
- ✅ Windows 10 22H2 Home  
- ✅ Windows 11 22H2 Pro
- ✅ Windows 11 22H2 Home
- ✅ PowerShell 5.1+

## 📞 Suporte

### Em caso de problemas:

1. **Primeiro:** Execute a opção 7 (Verificar instalações)
2. **Segundo:** Verifique os arquivos necessários estão presentes
3. **Terceiro:** Execute como administrador
4. **Quarto:** Verifique os logs de erro específicos

### Comando para diagnóstico rápido:
```powershell
# Verificar arquivos necessários
Write-Host "Verificando arquivos..."
Test-Path ".\LibreOffice_25.2.3_Win_x86-64.msi"
Test-Path ".\Oportuniza_WinCinza.png" 
Test-Path ".\Projeto.txt"
Write-Host "Verificando permissões..."
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
```

---

**Versão:** 2.0  
**Última atualização:** Julho 2025  
**Compatibilidade:** Windows 10/11 22H2
