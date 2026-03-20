. "$PSScriptRoot\lib-detect.ps1"

$script:SCRIPT_DIR = Split-Path -Parent $PSScriptRoot

function Install-DevTools {
    Write-Info "Installing development tools..."

    $pm = Get-PackageManager

    if ($pm -eq "winget") {
        Write-Info "Installing essential tools via winget..."
        $tools = @(
            "Git.Git",
            "Microsoft.VisualStudioCode",
            "Python.Python.3.11"
        )
        foreach ($tool in $tools) {
            winget install --id $tool -e --accept-package-agreements --accept-source-agreements --silent 2>$null
        }
    }
    elseif ($pm -eq "scoop") {
        Write-Info "Installing scoop bucket apps..."
        scoop bucket add extras 2>$null
        scoop install git vscode python 2>$null
    }
    elseif ($pm -eq "chocolatey") {
        Write-Info "Installing via chocolatey..."
        choco install git vscode python3 -y 2>$null
    }
    else {
        Write-Warn "No package manager available. Install manually:"
        Write-Info "  - Git: https://git-scm.com"
        Write-Info "  - VS Code: https://code.visualstudio.com"
        Write-Info "  - Python: https://python.org"
    }

    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Info "Git version: $(git --version)"
        git config --global core.autocrlf true
    }

    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Info "Python installed"
        python -m pip install --upgrade pip 2>$null
    }

    $nodeVersion = node --version 2>$null
    if (-not $nodeVersion) {
        Write-Info "Node.js not found. Installing via winget..."
        winget install -e --id OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements 2>$null
    } else {
        Write-Info "Node.js version: $nodeVersion"
    }

    Write-Success "Development tools installation complete"
}

if ($MyInvocation.InvocationName -ne ".") {
    Install-DevTools
}