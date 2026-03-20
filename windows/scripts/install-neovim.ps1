. "$PSScriptRoot\lib-detect.ps1"

$script:SCRIPT_DIR = Split-Path -Parent $PSScriptRoot
$script:REPO_ROOT = (Get-Item $script:SCRIPT_DIR).Parent.FullName

function Install-LazyVim {
    Write-Info "Installing LazyVim (Neovim)..."

    $nvimDir = "$env:USERPROFILE\.config\nvim"

    if (Test-Path $nvimDir) {
        Write-Warn "nvim config already exists at $nvimDir"
        $response = Read-Host "Overwrite? (y/N)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-Info "Skipping neovim installation"
            return
        }
        Backup-Config $nvimDir
    }

    $pm = Get-PackageManager
    if (-not $pm) {
        Write-Err "No package manager found."
        return
    }

    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        Write-Info "neovim already installed: $(nvim --version | Select-Object -First 1)"
    } else {
        Write-Info "Installing neovim via $pm..."
        switch ($pm) {
            "winget" {
                winget install --id Neovim.Neovim -e --accept-package-agreements --accept-source-agreements
            }
            "scoop" {
                scoop install neovim
            }
            "chocolatey" {
                choco install neovim -y
            }
        }
    }

    $configsPath = Join-Path $REPO_ROOT "configs\nvim"
    if (Test-Path $configsPath) {
        New-Item -ItemType Directory -Force -Path $nvimDir | Out-Null
        Copy-Item -Path "$configsPath\*" -Destination $nvimDir -Recurse -Force
        Write-Success "Copied nvim config to $nvimDir"
    }

    Write-Info "To complete LazyVim setup, run 'nvim' and wait for plugin installation."
    Write-Success "LazyVim installation complete"
}

if ($MyInvocation.InvocationName -ne ".") {
    Install-LazyVim
}