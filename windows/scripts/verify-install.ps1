# verify-install.ps1 - Verify installer file structure
# Usage: .\verify-install.ps1 [-All] [-Opencode] [-Nvim] [-Docker] [-Shell] [-Devtools] [-Engram] [-Installer]
# Exit codes: 0 = all passed, 1 = some failed

param(
    [switch]$All,
    [switch]$Opencode,
    [switch]$Nvim,
    [switch]$Docker,
    [switch]$Shell,
    [switch]$Devtools,
    [switch]$Engram,
    [switch]$Installer,
    [switch]$Help
)

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$REPO_ROOT = (Get-Item $SCRIPT_DIR).Parent.FullName

# Counters
$PASSED = 0
$FAILED = 0
$TOTAL = 0

# Colors
function Write-Pass { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Warn { param($msg) Write-Host "⚠ $msg" -ForegroundColor Yellow }
function Write-Info { param($msg) Write-Host "  $msg" -ForegroundColor Gray }

# Check if file exists
function Check-File {
    param($File, $Desc = "")
    $SCRIPT:TOTAL++
    $fullPath = Join-Path $REPO_ROOT $File
    if (Test-Path $fullPath) {
        $SCRIPT:PASSED++
        Write-Pass "$File$(if ($Desc) { " - $Desc" })"
    } else {
        $SCRIPT:FAILED++
        Write-Fail "$File$(if ($Desc) { " - $Desc" }) (NOT FOUND)"
    }
}

# Check if directory exists
function Check-Dir {
    param($Dir, $Desc = "")
    $SCRIPT:TOTAL++
    $fullPath = Join-Path $REPO_ROOT $Dir
    if (Test-Path $fullPath) {
        $SCRIPT:PASSED++
        Write-Pass "$Dir/$(if ($Desc) { $Desc })"
    } else {
        $SCRIPT:FAILED++
        Write-Fail "$Dir/$(if ($Desc) { $Desc }) (NOT FOUND)"
    }
}

# Check if content exists in file
function Check-Content {
    param($File, $Pattern, $Desc = "")
    $SCRIPT:TOTAL++
    $fullPath = Join-Path $REPO_ROOT $File
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw -ErrorAction SilentlyContinue
        if ($content -match $Pattern) {
            $SCRIPT:PASSED++
            Write-Pass "$File$(if ($Desc) { " - $Desc" })"
        } else {
            $SCRIPT:FAILED++
            Write-Fail "$File$(if ($Desc) { " - $Desc" }) (pattern not found)"
        }
    } else {
        $SCRIPT:FAILED++
        Write-Fail "$File$(if ($Desc) { " - $Desc" }) (FILE NOT FOUND)"
    }
}

# Verify opencode
function Verify-Opencode {
    Write-Host ""
    Write-Host "=== OpenCode ===" -ForegroundColor Cyan
    Check-Dir "configs\opencode" "config directory"
    Check-File "configs\opencode\orchestrator.md" "main config"
    Check-Dir "configs\opencode\skills" "skills directory"
}

# Verify nvim
function Verify-Nvim {
    Write-Host ""
    Write-Host "=== Neovim (LazyVim) ===" -ForegroundColor Cyan
    Check-Dir "configs\nvim" "nvim directory"
    Check-File "configs\nvim\init.lua" "init file"
    Check-File "configs\nvim\lua\plugins\themery.lua" "themery plugin"
    Check-File "configs\nvim\lua\config\nodejs.lua" "nodejs config"
    Check-File "configs\nvim\lazyvim.json" "lazyvim config"
}

# Verify docker
function Verify-Docker {
    Write-Host ""
    Write-Host "=== Docker ===" -ForegroundColor Cyan
    Check-Dir "configs\docker" "docker directory"
    Check-File "configs\docker\lazydocker.yml" "lazydocker config"
}

# Verify shell
function Verify-Shell {
    Write-Host ""
    Write-Host "=== Shell ===" -ForegroundColor Cyan
    Check-File "configs\bashrc" "bashrc"
    Check-File "configs\zshrc" "zshrc"
    Check-File "configs\profile" "profile"
}

# Verify devtools
function Verify-Devtools {
    Write-Host ""
    Write-Host "=== DevTools ===" -ForegroundColor Cyan
    Check-File "Brewfile" "Brewfile (macOS devtools)"
    Write-Info "DevTools verification is basic"
}

# Verify engram
function Verify-Engram {
    Write-Host ""
    Write-Host "=== Engram ===" -ForegroundColor Cyan
    Check-Dir "configs\opencode" "engram requires opencode structure"
    Check-File "configs\opencode\orchestrator.md" "orchestrator for engram"
}

# Verify installer code
function Verify-Installer {
    Write-Host ""
    Write-Host "=== Installer Code Verification ===" -ForegroundColor Cyan
    Check-Content "windows\scripts\install-neovim.ps1" "XDG_CONFIG_HOME" "XDG config in nvim installer"
    Check-Content "windows\scripts\link-configs.ps1" "\.config" "XDG path in link-configs"
}

# Print summary
function Print-Summary {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "Summary: $PASSED/$TOTAL passed, $FAILED failed"
    Write-Host "========================================"
    
    if ($FAILED -eq 0) {
        Write-Host "All checks passed!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Some checks failed!" -ForegroundColor Red
        exit 1
    }
}

# Usage
function Show-Usage {
    Write-Host "Usage: .\verify-install.ps1 [-All] [-Opencode] [-Nvim] [-Docker] [-Shell] [-Devtools] [-Engram] [-Installer]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -All       Verify all components"
    Write-Host "  -Opencode  Verify opencode config"
    Write-Host "  -Nvim      Verify neovim config"
    Write-Host "  -Docker    Verify docker config"
    Write-Host "  -Shell     Verify shell config"
    Write-Host "  -Devtools  Verify devtools"
    Write-Host "  -Engram    Verify engram"
    Write-Host "  -Installer Verify installer scripts"
    Write-Host "  -Help      Show this help"
    exit 0
}

# Main
function Main {
    $verifyAll = $false
    
    if ($Help) {
        Show-Usage
    }
    
    if (-not ($All -or $Opencode -or $Nvim -or $Docker -or $Shell -or $Devtools -or $Engram -or $Installer)) {
        $verifyAll = $true
    }
    
    if ($All) { $verifyAll = $true }
    
    if ($Opencode) { Verify-Opencode }
    if ($Nvim) { Verify-Nvim }
    if ($Docker) { Verify-Docker }
    if ($Shell) { Verify-Shell }
    if ($Devtools) { Verify-Devtools }
    if ($Engram) { Verify-Engram }
    if ($Installer) { Verify-Installer }
    
    if ($verifyAll) {
        Verify-Opencode
        Verify-Nvim
        Verify-Docker
        Verify-Shell
        Verify-Devtools
        Verify-Engram
        Verify-Installer
    }
    
    Print-Summary
}

Main
