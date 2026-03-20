. "$PSScriptRoot\lib-detect.ps1"

$script:SCRIPT_DIR = Split-Path -Parent $PSScriptRoot
$script:REPO_ROOT = (Get-Item $script:SCRIPT_DIR).Parent.FullName

function Link-Configs {
    Write-Info "Linking configuration files..."

    $configMappings = @{
        "configs\bashrc" = "$env:USERPROFILE\.bashrc"
        "configs\zshrc" = "$env:USERPROFILE\.zshrc"
        "configs\profile" = "$env:USERPROFILE\.profile"
    }

    foreach ($mapping in $configMappings.GetEnumerator()) {
        $src = Join-Path $REPO_ROOT $mapping.Key
        $dest = $mapping.Value

        if (Test-Path $src) {
            if (Test-Path $dest) {
                if (-not (Get-Item $dest).LinkType) {
                    Backup-Config $dest
                }
            }
            Copy-Item -Path $src -Destination $dest -Force
            Write-Success "Linked $($mapping.Key) -> $dest"
        }
    }

    $dirConfigs = @("nvim", "opencode", "lazydocker")
    foreach ($dir in $dirConfigs) {
        $src = Join-Path $REPO_ROOT "configs\$dir"
        $dest = "$env:USERPROFILE\.config\$dir"

        if (Test-Path $src) {
            if (Test-Path $dest) {
                if (-not (Get-Item $dest -ErrorAction SilentlyContinue).LinkType) {
                    Backup-Config $dest
                }
            } else {
                New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
            }
            Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
            Write-Success "Copied $dir configs to $dest"
        }
    }

    Write-Success "Config linking complete"
}

if ($MyInvocation.InvocationName -ne ".") {
    Link-Configs
}