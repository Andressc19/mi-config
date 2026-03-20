. "$PSScriptRoot\lib-detect.ps1"

$script:SCRIPT_DIR = Split-Path -Parent $PSScriptRoot

function Install-Docker {
    Write-Info "Installing Docker Stack..."

    $pm = Get-PackageManager
    if (-not $pm) {
        Write-Err "No package manager found."
        return
    }

    if (Get-Command docker -ErrorAction SilentlyContinue) {
        Write-Info "Docker already installed"
    } else {
        Write-Info "Installing Docker Desktop via $pm..."
        switch ($pm) {
            "winget" {
                winget install --id Docker.DockerDesktop -e --accept-package-agreements --accept-source-agreements
            }
            "scoop" {
                scoop install docker
            }
            "chocolatey" {
                choco install docker-desktop -y
            }
        }
        Write-Info "Docker Desktop requires manual start. Search 'Docker Desktop' in Start menu."
    }

    if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
        Write-Info "docker-compose already installed"
    } else {
        Write-Info "docker-compose not found. Install Docker Desktop to get it."
    }

    if (Get-Command lazydocker -ErrorAction SilentlyContinue) {
        Write-Info "lazydocker already installed"
    } else {
        Write-Info "lazydocker can be installed later via: scoop install lazydocker"
    }

    if ($WSL) {
        Write-Info "WSL detected - Docker Desktop integration is already configured"
    }

    Write-Success "Docker stack installation complete"
    Write-Info "Restart your computer after Docker Desktop installation"
}

if ($MyInvocation.InvocationName -ne ".") {
    Install-Docker
}