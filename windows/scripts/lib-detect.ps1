$Global:OS = "windows"
$Global:WSL = $false
$Global:DRY_RUN = $false

if ($env:WSL_DISTRO_NAME) {
    $Global:WSL = $true
    $Global:OS = "wsl"
}

function Get-OS {
    if ($env:WSL_DISTRO_NAME) { return "wsl" }
    return "windows"
}

function Get-OSVersion {
    return [System.Environment]::OSVersion.Version.ToString()
}

function Get-Architecture {
    return $env:PROCESSOR_ARCHITECTURE
}

function Get-PackageManager {
    if (Get-Command winget -ErrorAction SilentlyContinue) { 
        return "winget" 
    }
    if (Get-Command scoop -ErrorAction SilentlyContinue) { 
        return "scoop" 
    }
    if (Get-Command choco -ErrorAction SilentlyContinue) { 
        return "chocolatey" 
    }
    return $null
}

function Get-UserHome {
    return $env:USERPROFILE
}

function Get-ConfigDir {
    return "$env:USERPROFILE\.config"
}

function Test-Admin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-Info {
    param([string]$m)
    Write-Host "[INFO] $m" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$m)
    Write-Host "[SUCCESS] $m" -ForegroundColor Green
}

function Write-Warn {
    param([string]$m)
    Write-Host "[WARN] $m" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$m)
    Write-Host "[ERROR] $m" -ForegroundColor Red
}

function Backup-Config {
    param([string]$path)
    if (Test-Path $path) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupDir = "$env:USERPROFILE\backup-config-$timestamp"
        New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
        Copy-Item -Path $path -Destination $backupDir -Recurse -Force
        Write-Info "Backed up $path to $backupDir"
        return $backupDir
    }
    return $null
}

function Invoke-CommandWithRetry {
    param(
        [scriptblock]$Command,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 2
    )
    
    $attempt = 0
    while ($attempt -lt $MaxRetries) {
        try {
            return & $Command
        } catch {
            $attempt++
            if ($attempt -ge $MaxRetries) {
                throw
            }
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

function Show-Banner {
    @"

    ██████╗ ██████╗ ███████╗██╗██████╗ ██╗ █████╗ ███╗   ██╗
   ██╔═══██╗██╔══██╗██╔════╝██║██╔══██╗██║██╔══██╗████╗  ██║
   ██║   ██║██████╔╝███████╗██║██║  ██║██║███████║██╔██╗ ██║
   ██║   ██║██╔══██╗╚════██║██║██║  ██║██║██╔══██║██║╚██╗██║
   ╚██████╔╝██████╔╝███████║██║██████╔╝██║██║  ██║██║ ╚████║
    ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚══╝

              Multi-Platform Development Environment Installer
                            (Windows Edition)

"@
}

function Show-Help {
    @"

Usage: .\install.ps1 [OPTIONS]

Options:
    --all          Install everything
    --opencode     Install opencode + engram + skills + MCP
    --nvim         Install LazyVim + plugins
    --docker       Install Docker Desktop
    --shell        Install PowerShell profile, oh-my-posh
    --devtools     Install scoop/chocolatey/winget + tools
    --link         Link config files
    --dry-run      Show what would be installed without executing
    --help         Show this help message

Examples:
    .\install.ps1 -All                    # Full installation
    .\install.ps1 -Opencode -Nvim         # Install only opencode and neovim
    .\install.ps1 -DryRun -All            # Preview full installation

"@
}