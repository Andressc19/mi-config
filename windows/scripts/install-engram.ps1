param(
    [ValidateSet("Fork", "Upstream")]
    [string]$Source = "Fork"
)

. "$PSScriptRoot\lib-detect.ps1"

$ENGRAM_DIR = "$env:TEMP\engram"
$ENGRAM_BIN = "$env:LOCALAPPDATA\engram\engram.exe"
$ENGRAM_PLUGIN = "$env:APPDATA\opencode\plugins\engram.js"
$MIN_GO_VERSION = "1.25"

function Invoke-GitHubApi {
    param([string]$Endpoint)
    $headers = @{ "Accept" = "application/vnd.github+json" }
    if ($env:GH_TOKEN) {
        $headers["Authorization"] = "Bearer $env:GH_TOKEN"
    }
    $response = Invoke-RestMethod -Uri "https://api.github.com/$Endpoint" -Headers $headers
    return $response
}

function Get-EngramFromRelease {
    param([string]$Source)
    
    $repo = if ($Source -eq "Fork") { "Andressc19/mi-config" } else { "Gentleman-Programming/engram" }
    $owner = if ($Source -eq "Fork") { "Andressc19" } else { "Gentleman-Programming" }
    
    Write-Info "Fetching latest release from $repo..."
    
    $releases = Invoke-GitHubApi "repos/$owner/mi-config/releases/latest"
    $version = $releases.tag_name -replace '^v', ''
    
    Write-Info "Latest version: $version"
    
    $os = if ($IsWindows) { "windows" } elseif ($IsMacOS) { "darwin" } else { "linux" }
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "amd64" }
    
    $ext = if ($os -eq "windows") { "zip" } else { "tar.gz" }
    $filename = "engram_${os}_${arch}.${ext}"
    
    $downloadUrl = "https://github.com/$repo/releases/download/$($releases.tag_name)/$filename"
    
    Write-Info "Downloading: $filename"
    Write-Info "From: $downloadUrl"
    
    $tempFile = "$env:TEMP\$filename"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
    
    $installDir = "$env:LOCALAPPDATA\engram"
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    
    if ($ext -eq "zip") {
        Expand-Archive -Path $tempFile -DestinationPath $installDir -Force
    } else {
        tar -xzf $tempFile -C $installDir
    }
    
    $binPath = "$installDir\engram.exe"
    if (-not (Test-Path $binPath)) {
        $extracted = Get-ChildItem $installDir -Filter "engram*" | Select-Object -First 1
        if ($extracted) {
            Move-Item $extracted.FullName $binPath
        }
    }
    
    Write-Success "Engram installed to $binPath"
    return $binPath
}

function Test-GoInstalled {
    try {
        $goVersion = (go version -match 'go(\d+\.\d+)'); $matches[1]
        [version]$goVersion = $matches[1]
        [version]$minVersion = $MIN_GO_VERSION
        return $goVersion -ge $minVersion
    }
    catch {
        return $false
    }
}

function Install-Go {
    Write-Info "Go $MIN_GO_VERSION+ no encontrado. Instalando Go..."
    $installerUrl = "https://go.dev/dl/go1.23.0.windows-amd64.msi"
    $installerPath = "$env:TEMP\go-installer.msi"
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
    Start-Process msiexec.exe -ArgumentList "/i", $installerPath, "/quiet", "/norestart" -Wait
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-Success "Go instalado correctamente"
}

function Test-EngramInstalled {
    return Test-Path $ENGRAM_BIN
}

function Remove-EngramInstallation {
    if (Test-Path $ENGRAM_BIN) {
        Write-Warn "Eliminando instalacion anterior..."
        Remove-Item -Path "$env:LOCALAPPDATA\engram" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Get-EngramRepoUrl {
    if ($Source -eq "Fork") {
        return "git@github.com:Andressc19/engram.git"
    }
    return "https://github.com/Gentleman-Programming/engram.git"
}

function Install-Engram {
    Write-Info "Clonando repositorio Engram desde $Source..."
    
    if (Test-Path $ENGRAM_DIR) {
        Remove-Item -Path $ENGRAM_DIR -Recurse -Force
    }

    $repoUrl = Get-EngramRepoUrl
    git clone $repoUrl $ENGRAM_DIR
    
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Error al clonar el repositorio"
        exit 1
    }

    Write-Info "Construyendo Engram..."
    Set-Location $ENGRAM_DIR
    
    New-Item -Path "$env:LOCALAPPDATA\engram" -ItemType Directory -Force | Out-Null
    
    go build -o $ENGRAM_BIN ./cmd/engram
    
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Error al compilar Engram"
        exit 1
    }

    Write-Success "Engram compilado exitosamente"
}

function Add-ToPath {
    $pathEntry = "$env:LOCALAPPDATA\engram"
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    if ($currentPath -notlike "*$pathEntry*") {
        Write-Info "Agregando al PATH..."
        [System.Environment]::SetEnvironmentVariable(
            "Path",
            "$currentPath;$pathEntry",
            "User"
        )
        $env:Path += ";$pathEntry"
        Write-Success "PATH actualizado"
    }
}

function Verify-Installation {
    Write-Info "Verificando instalacion..."
    
    & $ENGRAM_BIN version
    
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Error al verificar instalacion"
        exit 1
    }
    
    Write-Success "Engram instalado y verificado"
}

function Setup-Opencode {
    Write-Info "Ejecutando setup opencode..."
    & $ENGRAM_BIN setup opencode
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Error en setup opencode (continuando...)"
    }
    else {
        Write-Success "Setup opencode completado"
    }
}

function Install-Plugin {
    Write-Info "Instalando plugin para opencode..."
    
    New-Item -Path "$env:APPDATA\opencode\plugins" -ItemType Directory -Force | Out-Null
    
    if (Test-Path $ENGRAM_DIR) {
        $pluginDir = Join-Path $ENGRAM_DIR "plugin"
        if (Test-Path $pluginDir) {
            Set-Location $pluginDir
            bun install
            
            if ($LASTEXITCODE -eq 0) {
                bun build engram.ts -o $ENGRAM_PLUGIN
                Write-Success "Plugin instalado"
            }
            else {
                Write-Warn "Error al compilar plugin (continuando...)"
            }
        }
        Set-Location $ENGRAM_DIR
    }
}

function Main {
    Write-Info "=== Instalador de Engram ==="
    Write-Info "Origen: $Source"
    
    if (Test-EngramInstalled) {
        Write-Warn "Engram ya esta instalado en $ENGRAM_BIN"
        $response = Read-Host "Desea sobreescribir? (s/n)"
        if ($response -ne "s") {
            Write-Info "Instalacion cancelada"
            exit 0
        }
        Remove-EngramInstallation
    }
    
    if ($Source -eq "Fork") {
        Get-EngramFromRelease -Source $Source
    }
    else {
        if (-not (Test-GoInstalled)) {
            Install-Go
        }
        else {
            Write-Info "Go instalado correctamente"
        }
        Install-Engram
    }
    
    Add-ToPath
    Verify-Installation
    Setup-Opencode
    Install-Plugin
    
    Write-Success "=== Instalacion completada ==="
}

Main
