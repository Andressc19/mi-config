. "$PSScriptRoot\lib-detect.ps1"

$script:SCRIPT_DIR = Split-Path -Parent $PSScriptRoot
$script:REPO_ROOT = (Get-Item $script:SCRIPT_DIR).Parent.FullName

$script:SKILLS_MODE = $null
$script:SKILLS_LIST = $null

function Parse-SkillsArgs {
    param([string[]]$Args)
    
    for ($i = 0; $i -lt $Args.Length; $i++) {
        switch ($Args[$i]) {
            "-Skills" {
                $script:SKILLS_MODE = "include"
                $script:SKILLS_LIST = $Args[$i + 1] -split ","
                $i++
            }
            "-ExcludeSkills" {
                $script:SKILLS_MODE = "exclude"
                $script:SKILLS_LIST = $Args[$i + 1] -split ","
                $i++
            }
        }
    }
}

function Install-Opencode {
    param(
        [string]$SkillsMode = $null,
        [string[]]$SkillsList = $null
    )
    
    Write-Info "Installing opencode..."

    $opencodeDir = "$env:USERPROFILE\.config\opencode"
    $opencodeBin = "$env:LOCALAPPDATA\opencode\opencode.exe"
    $manifestPath = Join-Path $REPO_ROOT "configs\opencode\skills-manifest.json"

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
        
        if ($SkillsMode -and (Test-Path $manifestPath)) {
            Install-SkillsWithFilter -OpencodeDir $opencodeDir -ManifestPath $manifestPath -SkillsMode $SkillsMode -SkillsList $SkillsList
        } else {
            Copy-Item -Path "$configsPath\*" -Destination $opencodeDir -Recurse -Force
            Write-Success "Copied opencode config to $opencodeDir"
        }
    }

    Write-Success "opencode installation complete"
}

function Install-SkillsWithFilter {
    param(
        [string]$OpencodeDir,
        [string]$ManifestPath,
        [string]$SkillsMode,
        [string[]]$SkillsList
    )
    
    $manifest = Get-SkillsManifest -ManifestPath $ManifestPath
    if (-not $manifest) {
        Write-Warn "Could not load skills manifest, installing all skills"
        Copy-Item -Path "$configsPath\*" -Destination $opencodeDir -Recurse -Force
        return
    }
    
    if ($SkillsMode -eq "include") {
        Write-Info "Installing selected skills: $($SkillsList -join ', ')"
        $filteredSkills = Get-FilteredSkills -Manifest $manifest -Mode "include" -SkillIds $SkillsList
    } elseif ($SkillsMode -eq "exclude") {
        Write-Info "Excluding skills: $($SkillsList -join ', ')"
        $filteredSkills = Get-FilteredSkills -Manifest $manifest -Mode "exclude" -SkillIds $SkillsList
    } else {
        $filteredSkills = $manifest.skills | Where-Object { $_.required -eq $false }
    }
    
    if (-not $filteredSkills) {
        Write-Err "No skills to install"
        return
    }
    
    $requiredSkills = $manifest.skills | Where-Object { $_.required -eq $true }
    
    foreach ($skill in $filteredSkills) {
        Install-Skill -OpencodeDir $opencodeDir -SkillId $skill.id -Source $skill.source -Path $skill.path -RepoRoot $REPO_ROOT
    }
    
    foreach ($skill in $requiredSkills) {
        Install-Skill -OpencodeDir $opencodeDir -SkillId $skill.id -Source $skill.source -Path $skill.path -RepoRoot $REPO_ROOT
    }
    
    Write-Success "Installed $($filteredSkills.Count + $requiredSkills.Count) skills"
}

if ($MyInvocation.InvocationName -ne ".") {
    Parse-SkillsArgs -Args $args
    Install-Opencode -SkillsMode $SKILLS_MODE -SkillsList $SKILLS_LIST
}