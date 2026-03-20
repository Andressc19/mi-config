#!/usr/bin/env pwsh
# =============================================================================
# mi-config Bootstrap Installer
# Usage: irm https://.../bootstrap.ps1 | iex
# Or: .\bootstrap.ps1 -All
# =============================================================================

$ErrorActionPreference = "Continue"
$REPO_URL = "https://raw.githubusercontent.com/Andressc19/mi-config/main"
$ENGRAM_RELEASES = "https://api.github.com/repos/Gentleman-Programming/engram/releases/latest"
$TEMP_DIR = Join-Path $env:TEMP "mi-config-$(Get-Random)"

# Parse arguments
$All = $false
$Opencode = $false
$Nvim = $false
$Docker = $false
$Shell = $false
$Help = $false

foreach ($arg in $args) {
    switch ($arg.ToLower()) {
        { $_ -in "-all","--all" } { $All = $true }
        { $_ -in "-opencode","--opencode" } { $Opencode = $true }
        { $_ -in "-nvim","--nvim" } { $Nvim = $true }
        { $_ -in "-docker","--docker" } { $Docker = $true }
        { $_ -in "-shell","--shell" } { $Shell = $true }
        { $_ -in "-help","--help" } { $Help = $true }
    }
}

function Write-Color {
    param([string]$Message, [string]$Color = "White")
    try {
        $foreColor = [System.ConsoleColor]::White
        switch ($Color) {
            "Red" { $foreColor = [System.ConsoleColor]::Red }
            "Green" { $foreColor = [System.ConsoleColor]::Green }
            "Yellow" { $foreColor = [System.ConsoleColor]::Yellow }
            "Cyan" { $foreColor = [System.ConsoleColor]::Cyan }
            "Gray" { $foreColor = [System.ConsoleColor]::DarkGray }
        }
        Write-Host $Message -ForegroundColor $foreColor
    } catch {
        Write-Host $Message
    }
}

function Get-PackageManager {
    if (Get-Command winget -ErrorAction SilentlyContinue) { return "winget" }
    if (Get-Command scoop -ErrorAction SilentlyContinue) { return "scoop" }
    if (Get-Command choco -ErrorAction SilentlyContinue) { return "chocolatey" }
    return $null
}

function Install-WithWinget {
    param([string]$PackageId, [string]$Name)
    Write-Color "  Installing $Name via winget..." "Cyan"
    winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Color "  [OK] $Name installed" "Green"
        return $true
    }
    return $false
}

function Install-Git {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        Write-Color "Installing Git..." "Cyan"
        switch (Get-PackageManager) {
            "winget" { Install-WithWinget "Git.Git" "Git" }
            "scoop" { scoop install git }
            "chocolatey" { choco install git -y }
            default {
                Write-Color "  [ERROR] Git not found. Please install Git first." "Red"
                return $false
            }
        }
    } else {
        Write-Color "  [OK] Git already installed: $(git --version)" "Green"
    }
    return $true
}

function Install-Engram {
    Write-Color "`n[Engram - Persistent Memory]" "Cyan"
    
    $engramCmd = Get-Command engram -ErrorAction SilentlyContinue
    if ($engramCmd) {
        $version = & engram --version 2>$null
        Write-Color "  [OK] Engram already installed: $version" "Green"
        return
    }
    
    Write-Color "  Installing Engram..." "Cyan"
    
    # Try winget first
    if ((Get-PackageManager) -eq "winget") {
        $wingetSuccess = Install-WithWinget "Gentleman-Programming.Engram" "Engram"
        if ($wingetSuccess) {
            Write-Color "  [OK] Engram installed via winget" "Green"
            return
        }
    }
    
    # Download from GitHub releases
    try {
        Write-Color "  Downloading from GitHub..." "Cyan"
        $response = Invoke-RestMethod -Uri $ENGRAM_RELEASES -UseBasicParsing
        $version = $response.tag_name -replace 'v',''
        
        # Find Windows amd64 asset
        $asset = $response.assets | Where-Object { $_.name -match "windows_amd64\.zip" } | Select-Object -First 1
        
        if ($asset) {
            $zipPath = Join-Path $env:TEMP "engram.zip"
            $extractDir = Join-Path $env:TEMP "engram"
            
            Write-Color "  Downloading Engram v$version..." "Cyan"
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -UseBasicParsing
            
            # Extract
            Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
            $exePath = Join-Path $extractDir "engram.exe"
            
            # Move to PATH
            $targetDir = Join-Path $env:LOCALAPPDATA "Programs\engram"
            New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
            Move-Item -Path $exePath -Destination $targetDir -Force
            
            # Add to PATH if not already
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath -notlike "*$targetDir*") {
                [Environment]::SetEnvironmentVariable("Path", "$userPath;$targetDir", "User")
                $env:Path = "$env:Path;$targetDir"
            }
            
            # Cleanup
            Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
            Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
            
            Write-Color "  [OK] Engram v$version installed" "Green"
            Write-Color "  Location: $targetDir\engram.exe" "Gray"
        }
    } catch {
        Write-Color "  [WARN] Could not download Engram automatically" "Yellow"
        Write-Color "  Manual install: https://github.com/Gentleman-Programming/engram/releases" "Yellow"
    }
}

function Install-Opencode {
    Write-Color "`n[opencode + Engram]" "Cyan"
    
    # Install Engram first
    Install-Engram
    
    # Create config directories
    $opencodeDir = Join-Path $env:USERPROFILE ".config\opencode"
    $engramDir = Join-Path $env:USERPROFILE ".engram"
    
    New-Item -ItemType Directory -Force -Path $opencodeDir | Out-Null
    New-Item -ItemType Directory -Force -Path $engramDir | Out-Null
    
    Write-Color "  Downloading opencode config..." "Cyan"
    
    # Download configs from repo
    $configs = @("opencode.json", "package.json", "orchestrator.md")
    
    foreach ($config in $configs) {
        $url = "$REPO_URL/configs/opencode/$config"
        $dest = Join-Path $opencodeDir $config
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing 2>$null
            Write-Color "    [OK] $config" "Green"
        } catch {
            Write-Color "    [SKIP] $config" "Gray"
        }
    }
    
    # Download skills
    $skillsDir = Join-Path $opencodeDir "skills"
    New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
    
    Write-Color "  [OK] opencode config downloaded" "Green"
    
    # Run engram setup opencode
    $engramExe = Join-Path $env:LOCALAPPDATA "Programs\engram\engram.exe"
    if (Test-Path $engramExe) {
        Write-Color "  Running 'engram setup opencode'..." "Cyan"
        & $engramExe setup opencode 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Color "  [OK] opencode configured with Engram" "Green"
        }
    }
}

function Install-LazyVim {
    Write-Color "`n[LazyVim]" "Cyan"
    
    $nvimDir = Join-Path $env:USERPROFILE ".config\nvim"
    
    $nvim = Get-Command nvim -ErrorAction SilentlyContinue
    if (-not $nvim) {
        Write-Color "  Installing Neovim..." "Cyan"
        switch (Get-PackageManager) {
            "winget" { Install-WithWinget "Neovim.Neovim" "Neovim" }
            "scoop" { scoop install neovim }
            "chocolatey" { choco install neovim -y }
            default {
                Write-Color "  [ERROR] Neovim not found and no package manager available." "Red"
                Write-Color "  Install manually: https://github.com/neovim/neovim/releases" "Yellow"
                return
            }
        }
    } else {
        Write-Color "  [OK] Neovim already installed: $(nvim --version | Select-Object -First 1)" "Green"
    }
    
    if (-not (Test-Path $nvimDir)) {
        Write-Color "  Setting up LazyVim..." "Cyan"
        New-Item -ItemType Directory -Force -Path $nvimDir | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $nvimDir "lua\plugins") | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $nvimDir "lua\config") | Out-Null
        
        # Download init.lua
        try {
            Invoke-WebRequest -Uri "$REPO_URL/configs/nvim/init.lua" -OutFile (Join-Path $nvimDir "init.lua") -UseBasicParsing
            Invoke-WebRequest -Uri "$REPO_URL/configs/nvim/lazyvim.json" -OutFile (Join-Path $nvimDir "lazyvim.json") -UseBasicParsing
            Write-Color "    [OK] init.lua, lazyvim.json" "Green"
        } catch {
            Write-Color "    [WARN] Could not download configs" "Yellow"
        }
        
        Write-Color "  [OK] LazyVim structure created" "Green"
        Write-Color "  Run 'nvim' to complete plugin installation" "Yellow"
    } else {
        Write-Color "  [WARN] LazyVim config already exists" "Yellow"
    }
}

function Install-Docker {
    Write-Color "`n[Docker Desktop]" "Cyan"
    
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $docker) {
        Write-Color "  Installing Docker Desktop..." "Cyan"
        switch (Get-PackageManager) {
            "winget" {
                Write-Color "  [INFO] Please install Docker Desktop manually:" "Yellow"
                Write-Color "    https://www.docker.com/products/docker-desktop/" "Cyan"
            }
            "scoop" { 
                scoop install docker docker-compose
                Write-Color "  [OK] Docker installed via scoop" "Green"
            }
            "chocolatey" { 
                choco install docker-desktop -y
                Write-Color "  [OK] Docker installed via chocolatey" "Green"
            }
            default {
                Write-Color "  [ERROR] No package manager found" "Red"
            }
        }
    } else {
        Write-Color "  [OK] Docker already installed: $(docker --version)" "Green"
    }
}

function Install-OhMyPosh {
    Write-Color "`n[Oh My Posh]" "Cyan"
    
    $ohmyposh = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if (-not $ohmyposh) {
        Write-Color "  Installing Oh My Posh..." "Cyan"
        switch (Get-PackageManager) {
            "winget" { Install-WithWinget "JanDeDobbeleer.OhMyPosh" "Oh My Posh" }
            "scoop" { scoop install oh-my-posh }
            "chocolatey" { choco install oh-my-posh -y }
        }
    } else {
        Write-Color "  [OK] Oh My Posh already installed" "Green"
    }
    
    $profilePath = $PROFILE
    $profileDir = Split-Path $profilePath -Parent
    
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    }
    
    $ohMyPoshLine = "oh-my-posh init pwsh | Invoke-Expression"
    
    if (-not (Test-Path $profilePath)) {
        Set-Content -Path $profilePath -Value $ohMyPoshLine
        Write-Color "  [OK] PowerShell profile created" "Green"
    } elseif (-not (Select-String -Path $profilePath -Pattern "oh-my-posh" -Quiet)) {
        Add-Content -Path $profilePath -Value $ohMyPoshLine
        Write-Color "  [OK] Added Oh My Posh to profile" "Green"
    } else {
        Write-Color "  [OK] Oh My Posh already in profile" "Green"
    }
}

function Show-Banner {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  mi-config Bootstrap Installer v2.0" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Help {
    Write-Host "Usage:"
    Write-Host "  irm https://.../bootstrap.ps1 | iex -All"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -All       Install everything (default)"
    Write-Host "  -Opencode  Install opencode + Engram"
    Write-Host "  -Nvim      Install LazyVim"
    Write-Host "  -Docker    Install Docker"
    Write-Host "  -Shell     Install Oh My Posh"
    Write-Host "  -Help      Show this help"
    Write-Host ""
}

# =============================================================================
# Main
# =============================================================================

Show-Banner

Write-Color "System Info:" "White"
Write-Color "  OS: Windows $($PSVersionTable.PSVersion)" "Gray"
Write-Color "  Package Manager: $(Get-PackageManager)" "Gray"
Write-Host ""

$doAll = $All -or (-not $Opencode -and -not $Nvim -and -not $Docker -and -not $Shell)

if ($Help) {
    Show-Help
    exit 0
}

$hasGit = Install-Git
if (-not $hasGit) {
    Write-Color "`n[ERROR] Please install Git first." "Red"
    exit 1
}

Write-Color "Cloning repository..." "Cyan"
try {
    git clone --depth 1 https://github.com/Andressc19/mi-config.git $TEMP_DIR 2>$null
    Write-Color "  [OK] Repository cloned" "Green"
} catch {
    Write-Color "  [SKIP] Could not clone repo" "Gray"
}

if ($doAll -or $Opencode) { Install-Opencode }
if ($doAll -or $Nvim) { Install-LazyVim }
if ($doAll -or $Docker) { Install-Docker }
if ($doAll -or $Shell) { Install-OhMyPosh }

if (Test-Path $TEMP_DIR) {
    Remove-Item -Recurse -Force $TEMP_DIR -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Color "Next steps:" "White"
Write-Color "  1. Restart your terminal" "Yellow"
Write-Color "  2. Run 'nvim' to setup LazyVim" "Yellow"
Write-Color "  3. Run 'opencode' to start" "Yellow"
Write-Host ""
