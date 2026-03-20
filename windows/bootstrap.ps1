#!/usr/bin/env pwsh
# =============================================================================
# mi-config Bootstrap Installer
# Usage: irm https://.../bootstrap.ps1 | iex
# Or: .\bootstrap.ps1 -All
# =============================================================================

$ErrorActionPreference = "Continue"
$REPO_URL = "https://raw.githubusercontent.com/Andressc19/mi-config/main"
$TEMP_DIR = Join-Path $env:TEMP "mi-config-$(Get-Random)"

# Parse arguments (works both from pipeline and file)
$All = $false
$Opencode = $false
$Nvim = $false
$Docker = $false
$Shell = $false
$Help = $false

foreach ($arg in $args) {
    switch ($arg.ToLower()) {
        "-all" { $All = $true }
        "-opencode" { $Opencode = $true }
        "-nvim" { $Nvim = $true }
        "-docker" { $Docker = $true }
        "-shell" { $Shell = $true }
        "-help" { $Help = $true }
        "--all" { $All = $true }
        "--opencode" { $Opencode = $true }
        "--nvim" { $Nvim = $true }
        "--docker" { $Docker = $true }
        "--shell" { $Shell = $true }
        "--help" { $Help = $true }
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
    } else {
        Write-Color "  [WARN] $Name may already be installed" "Yellow"
    }
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

function Install-Opencode {
    Write-Color "`n[opencode + Engram]" "Cyan"
    
    $opencodeDir = Join-Path $env:USERPROFILE ".config\opencode"
    $engramDir = Join-Path $env:USERPROFILE ".engram"
    
    New-Item -ItemType Directory -Force -Path $opencodeDir | Out-Null
    New-Item -ItemType Directory -Force -Path $engramDir | Out-Null
    
    Write-Color "  Downloading opencode config..." "Cyan"
    
    $configs = @("opencode.json", "package.json", "orchestrator.md")
    
    foreach ($config in $configs) {
        $url = "$REPO_URL/configs/opencode/$config"
        $dest = Join-Path $opencodeDir $config
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing 2>$null
            Write-Color "    [OK] $config" "Green"
        } catch {
            Write-Color "    [WARN] $config skipped" "Yellow"
        }
    }
    
    Write-Color "  [OK] opencode + Engram config downloaded" "Green"
    Write-Color "  Run: go install github.com/engramhq/engram@latest" "Yellow"
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
        }
    } else {
        Write-Color "  [OK] Neovim already installed" "Green"
    }
    
    if (-not (Test-Path $nvimDir)) {
        Write-Color "  Setting up LazyVim..." "Cyan"
        New-Item -ItemType Directory -Force -Path $nvimDir | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $nvimDir "lua") | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $nvimDir "lua\plugins") | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $nvimDir "lua\config") | Out-Null
        
        try {
            Invoke-WebRequest -Uri "$REPO_URL/configs/nvim/init.lua" -OutFile (Join-Path $nvimDir "init.lua") -UseBasicParsing
            Write-Color "    [OK] init.lua" "Green"
        } catch {}
        
        Write-Color "  [OK] LazyVim structure created" "Green"
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
                Write-Color "  [INFO] Install manually: https://docker.com/get-started" "Cyan"
            }
            "scoop" { scoop install docker docker-compose }
            "chocolatey" { choco install docker-desktop -y }
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
    Write-Host "  mi-config Bootstrap Installer" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Help {
    Write-Host "Usage:"
    Write-Host "  irm https://.../bootstrap.ps1 | iex -All"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -All       Install everything (default)"
    Write-Host "  -Opencode  Install opencode + engram"
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
    Write-Color "  [WARN] Could not clone, using direct downloads" "Yellow"
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
Write-Color "  3. Full installer: cd mi-config\windows; .\install.ps1" "Yellow"
Write-Host ""
