param(
    [switch]$All,
    [switch]$Opencode,
    [switch]$Nvim,
    [switch]$Docker,
    [switch]$Shell,
    [switch]$Devtools,
    [switch]$Link,
    [switch]$Engram,
    [string]$EngramSource,
    [switch]$DryRun,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$REPO_ROOT = (Get-Item $SCRIPT_DIR).Parent.FullName
$Global:ENGRAM_SOURCE = "Fork"

. "$SCRIPT_DIR\scripts\lib-detect.ps1"

function Get-UserSelection {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║           Development Environment Installer              ║" -ForegroundColor Cyan
    Write-Host "  ║                  (Windows Edition)                       ║" -ForegroundColor Cyan
    Write-Host "  ║                                                           ║" -ForegroundColor Cyan
    Write-Host "  ║  Select components to install:                           ║" -ForegroundColor Cyan
    Write-Host "  ║                                                           ║" -ForegroundColor Cyan
    Write-Host "  ║    [1] All components                                    ║" -ForegroundColor White
    Write-Host "  ║    [2] opencode + engram + skills + MCP                 ║" -ForegroundColor White
    Write-Host "  ║    [E] Engram (persistent memory)                        ║" -ForegroundColor White
    Write-Host "  ║    [3] LazyVim (Neovim) + plugins                        ║" -ForegroundColor White
    Write-Host "  ║    [4] Docker Desktop                                    ║" -ForegroundColor White
    Write-Host "  ║    [5] Shell (PowerShell + oh-my-posh)                  ║" -ForegroundColor White
    Write-Host "  ║    [6] Dev tools (git, vscode, python, node)            ║" -ForegroundColor White
    Write-Host "  ║    [7] Link all configs                                  ║" -ForegroundColor White
    Write-Host "  ║                                                           ║" -ForegroundColor White
    Write-Host "  ║    [Q] Quit                                              ║" -ForegroundColor Yellow
    Write-Host "  ╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    $selection = Read-Host "Enter your choice"
    return $selection.ToLower()
}

function Show-SystemInfo {
    $os = Get-OS
    $pm = Get-PackageManager
    $isAdmin = Test-Admin
    
    Write-Host "" -ForegroundColor Gray
    Write-Host "  Detected OS: Windows" -ForegroundColor Gray
    if ($WSL) {
        Write-Host "  WSL: Enabled ($env:WSL_DISTRO_NAME)" -ForegroundColor Gray
    }
    Write-Host "  Package Manager: $pm" -ForegroundColor Gray
    Write-Host "  Admin: $(if ($isAdmin) { 'Yes' } else { 'No' })" -ForegroundColor Gray
    Write-Host ""
}

function Run-Install {
    param(
        [string]$Script,
        [string]$Name
    )
    
    if ($DryRun) {
        Write-Info "[DRY-RUN] Would execute: $Script"
        return
    }
    
    Write-Info "Installing $Name..."
    & $SCRIPT_DIR\scripts\$Script
}

function Show-EngramSourceMenu {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║              Engram Source Selection                     ║" -ForegroundColor Cyan
    Write-Host "  ║                                                           ║" -ForegroundColor Cyan
    Write-Host "  ║  Select Engram source:                                    ║" -ForegroundColor Cyan
    Write-Host "  ║                                                           ║" -ForegroundColor Cyan
    Write-Host "  ║    [1] Fork (default - my configuration)                 ║" -ForegroundColor White
    Write-Host "  ║    [2] Upstream (original repository)                      ║" -ForegroundColor White
    Write-Host "  ║                                                           ║" -ForegroundColor White
    Write-Host "  ╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    $sourceSelection = Read-Host "Enter your choice (1-2)"
    return $sourceSelection
}

function Main {
    if ($Help) {
        Show-Banner
        Show-Help
        return
    }

    Show-Banner
    Show-SystemInfo

    if ($Engram -and -not $EngramSource) {
        $sourceSelection = Show-EngramSourceMenu
        switch ($sourceSelection) {
            "1" { $EngramSource = "Fork" }
            "2" { $EngramSource = "Upstream" }
            default { $EngramSource = "Fork" }
        }
    }

    if (-not $All -and -not $Opencode -and -not $Nvim -and -not $Docker -and -not $Shell -and -not $Devtools -and -not $Link -and -not $Engram) {
        $selection = Get-UserSelection
        
        switch ($selection) {
            "1" { $All = $true }
            "2" { $Opencode = $true }
            "3" { $Nvim = $true }
            "4" { $Docker = $true }
            "5" { $Shell = $true }
            "6" { $Devtools = $true }
            "7" { $Link = $true }
            "e" { $Engram = $true }
            "q" { 
                Write-Host "Exiting..." -ForegroundColor Yellow
                return 
            }
            default {
                Write-Err "Invalid option"
                return
            }
        }
    }

    Write-Info "Starting installation..."

    if ($Link) {
        Run-Install "link-configs.ps1" "config files"
    }

    if ($Devtools) {
        Run-Install "install-devtools.ps1" "development tools"
    }

    if ($Shell) {
        Run-Install "install-shell.ps1" "shell configurations"
    }

    if ($Opencode) {
        Run-Install "install-opencode.ps1" "opencode"
    }

    if ($Nvim) {
        Run-Install "install-neovim.ps1" "LazyVim"
    }

    if ($Docker) {
        Run-Install "install-docker.ps1" "Docker stack"
    }

    if ($Engram) {
        $source = if ($EngramSource) { $EngramSource } else { $ENGRAM_SOURCE }
        $scriptPath = "$SCRIPT_DIR\scripts\install-engram.ps1"
        if ($source -eq "Fork") {
            & $scriptPath -Source Fork
        } else {
            & $scriptPath -Source Upstream
        }
    }

    Write-Host ""
    Write-Success "Installation complete!"

    if ($DryRun) {
        Write-Info "This was a dry run. Run without -DryRun to execute."
    }

    Write-Host ""
    Write-Info "Next steps:"
    Write-Info "  - Restart your terminal"
    Write-Info "  - Run 'nvim' to complete LazyVim setup"
    Write-Info "  - Run 'opencode' to start using opencode"
}

Main