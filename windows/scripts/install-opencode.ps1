. "$PSScriptRoot\lib-detect.ps1"

$script:SCRIPT_DIR = Split-Path -Parent $PSScriptRoot
$script:REPO_ROOT = (Get-Item $script:SCRIPT_DIR).Parent.FullName

function Install-Opencode {
    Write-Info "Installing opencode..."

    $opencodeDir = "$env:USERPROFILE\.config\opencode"
    $opencodeBin = "$env:LOCALAPPDATA\opencode\opencode.exe"

    if (Test-Path $opencodeDir) {
        Write-Warn "opencode config already exists at $opencodeDir"
        $response = Read-Host "Overwrite? (y/N)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-Info "Skipping opencode installation"
            return
        }
        Backup-Config $opencodeDir
    }

    $pm = Get-PackageManager
    if (-not $pm) {
        Write-Err "No package manager found. Install winget, scoop, or chocolatey first."
        return
    }

    if (Get-Command opencode -ErrorAction SilentlyContinue) {
        Write-Info "opencode already installed"
    } else {
        Write-Info "Installing opencode via $pm..."
        switch ($pm) {
            "winget" {
                winget install --id OpenCodeAI.OpenCode -e --accept-package-agreements --accept-source-agreements
            }
            "scoop" {
                scoop install opencode
            }
            "chocolatey" {
                choco install opencode -y
            }
        }
    }

    $configsPath = Join-Path $REPO_ROOT "configs\opencode"
    if (Test-Path $configsPath) {
        New-Item -ItemType Directory -Force -Path $opencodeDir | Out-Null
        Copy-Item -Path "$configsPath\*" -Destination $opencodeDir -Recurse -Force
        Write-Success "Copied opencode config to $opencodeDir"
    }

    Write-Success "opencode installation complete"
}

if ($MyInvocation.InvocationName -ne ".") {
    Install-Opencode
}