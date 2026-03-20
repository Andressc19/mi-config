. "$PSScriptRoot\lib-detect.ps1"

$script:SCRIPT_DIR = Split-Path -Parent $PSScriptRoot
$script:REPO_ROOT = (Get-Item $script:SCRIPT_DIR).Parent.FullName

function Install-Shell {
    Write-Info "Installing PowerShell + oh-my-posh..."

    $pm = Get-PackageManager
    if (-not $pm) {
        Write-Err "No package manager found."
        return
    }

    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        Write-Info "PowerShell Core already installed: $(pwsh --version)"
    } else {
        Write-Info "Installing PowerShell Core via $pm..."
        switch ($pm) {
            "winget" {
                winget install --id Microsoft.PowerShell -e --accept-package-agreements --accept-source-agreements
            }
            "scoop" {
                scoop install powershell
            }
            "chocolatey" {
                choco install powershell-core -y
            }
        }
    }

    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        Write-Info "oh-my-posh already installed"
    } else {
        Write-Info "Installing oh-my-posh via $pm..."
        switch ($pm) {
            "winget" {
                winget install --id JanDeDobbeleer.OhMyPosh -e --accept-package-agreements --accept-source-agreements
            }
            "scoop" {
                scoop install oh-my-posh
            }
            "chocolatey" {
                choco install oh-my-posh -y
            }
        }
    }

    $userShell = $PROFILE
    $userShellDir = Split-Path -Parent $userShell
    
    if (-not (Test-Path $userShellDir)) {
        New-Item -ItemType Directory -Force -Path $userShellDir | Out-Null
    }

    $configsPath = Join-Path $REPO_ROOT "configs\pwsh"
    if (Test-Path $configsPath) {
        Copy-Item -Path "$configsPath\*" -Destination $userShellDir -Recurse -Force
        Write-Success "Copied PowerShell config"
    } else {
        if (-not (Test-Path $userShell)) {
            $profileContent = @"
# PowerShell Profile
Import-Module oh-my-posh
Set-Theme Paradox
"@
            Set-Content -Path $userShell -Value $profileContent
            Write-Success "Created PowerShell profile"
        }
    }

    Write-Info "To enable oh-my-posh theme, add to your `$PROFILE:"
    Write-Info "  Import-Module oh-my-posh"
    Write-Info "  Set-Theme <theme-name>"
    Write-Info "Available themes: paradox, jandedobbeleer, laser, etc."
    
    Write-Success "Shell installation complete"
}

if ($MyInvocation.InvocationName -ne ".") {
    Install-Shell
}