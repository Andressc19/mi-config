# Windows Installation Guide

> Multi-platform development environment installer for Windows (PowerShell)

## Quick Install

### Method 1: Direct Execution
```powershell
# Clone and run
git clone https://github.com/Andressc19/mi-config.git
cd mi-config\windows
.\install.ps1 -All
```

### Method 2: With Execution Policy (if restricted)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1 -All
```

## Requirements

### Windows Version
- Windows 10 (build 1809+) or Windows 11

### Package Manager (one required)
1. **winget** (recommended) - Windows Package Manager
2. **scoop** - Alternative package manager
3. **chocolatey** - Legacy package manager

Check which you have:
```powershell
Get-Command winget  # Preferred
Get-Command scoop
Get-Command choco
```

## Installation Options

### Full Installation
```powershell
.\install.ps1 -All
```

### Selective Installation
```powershell
# Install only opencode
.\install.ps1 -Opencode

# Install only LazyVim
.\install.ps1 -Nvim

# Install Docker Desktop
.\install.ps1 -Docker

# Install shell (PowerShell + oh-my-posh)
.\install.ps1 -Shell

# Install dev tools (git, vscode, python, node)
.\install.ps1 -Devtools

# Link config files
.\install.ps1 -Link

# Multiple components
.\install.ps1 -Opencode -Nvim -Shell
```

### Dry Run
Preview what would be installed without executing:
```powershell
.\install.ps1 -All -DryRun
```

### Interactive Mode
Run without flags for interactive menu:
```powershell
.\install.ps1
```

## Installed Components

### opencode
- AI coding assistant
- engram persistent memory plugin
- SDD skills (sdd-init, sdd-spec, etc.)
- MCP integrations

### LazyVim (Neovim)
- Neovim with LazyVim starter
- Tokyo Night theme
- Plugin management via Lazy

### Docker Desktop
- Docker Engine
- docker-compose
- WSL2 integration (if WSL detected)

### PowerShell Shell
- PowerShell Core (pwsh)
- oh-my-posh prompts
- Terminal icons

### Dev Tools
- Git
- Visual Studio Code
- Python
- Node.js (via winget)

## Configuration Paths

| Component | Windows Path |
|-----------|---------------|
| opencode config | `%USERPROFILE%\.config\opencode` |
| Neovim config | `%USERPROFILE%\.config\nvim` |
| Engram DB | `%USERPROFILE%\.engram\default.db` |
| PowerShell profile | `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |

## Backup & Restore

### Engram Backup
```powershell
# Create backup
.\scripts\backup-engram.ps1 -Backup

# List backups
.\scripts\backup-engram.ps1 -List

# Show database stats
.\scripts\backup-engram.ps1 -Stats

# Restore from backup
.\scripts\backup-engram.ps1 -Restore -BackupPath "C:\path\to\backup.zip"
```

Backups are stored in: `%USERPROFILE%\engram-backups\`

## Uninstall

To remove installed components:
```powershell
# Remove opencode
winget uninstall OpenCodeAI.OpenCode

# Remove Neovim
winget uninstall Neovim.Neovim

# Remove Docker Desktop (via Start menu)
```

## Troubleshooting

### "Running scripts is disabled"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "winget not found"
Install from Microsoft Store or: https://github.com/microsoft/winget-cli

### Docker not starting
- Enable WSL2 in Windows Features
- Install Docker Desktop from: https://docker.com/get-started

### oh-my-posh not loading
Add to your PowerShell profile:
```powershell
Import-Module oh-my-posh
Set-Theme paradox
```

## WSL Integration

If running in WSL, consider:
1. Using the Linux install script (`../install.sh`)
2. Docker Desktop with WSL2 backend integration

## License

MIT