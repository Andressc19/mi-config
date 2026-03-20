# PowerShell Profile for Windows Development Environment

# oh-my-posh theme
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression

# Aliases
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String

# Environment
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

# Load NVM for Node.js (if installed)
$NVM_HOME = "$env:APPDATA\nvm"
if (Test-Path $NVM_HOME) {
    Import-Module "$NVM_HOME\nvm.psm1" -ErrorAction SilentlyContinue
}

# Docker completion
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -CommandName docker -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        docker 2>$null | ForEach-Object {
            if ($_ -match "^(\S+)") {
                [System.Management.Automation.CompletionResult]::new($matches[1], $matches[1], 'Parameter', $matches[1])
            }
        }
    }
}