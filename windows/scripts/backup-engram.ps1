# Engram Backup Script
# Backup and restore Engram persistent memory database

param(
    [switch]$Backup,
    [switch]$Restore,
    [string]$BackupPath,
    [switch]$List,
    [switch]$Stats
)

$ErrorActionPreference = "Stop"

function Get-EngramDbPath {
    if ($env:ENGRAM_DB_PATH) {
        return $env:ENGRAM_DB_PATH
    }
    
    $defaultPath = "$env:USERPROFILE\.engram\default.db"
    if (Test-Path $defaultPath) {
        return $defaultPath
    }
    
    $altPath = "$env:APPDATA\engram\default.db"
    if (Test-Path $altPath) {
        return $altPath
    }
    
    return $null
}

function Get-BackupDir {
    $backupDir = "$env:USERPROFILE\engram-backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
    }
    return $backupDir
}

function Backup-Engram {
    $dbPath = Get-EngramDbPath
    
    if (-not $dbPath) {
        Write-Host "[ERROR] Engram database not found" -ForegroundColor Red
        Write-Host "Ensure Engram is installed and has been used at least once" -ForegroundColor Yellow
        return
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = Get-BackupDir
    
    if ($BackupPath) {
        $backupFile = $BackupPath
    } else {
        $backupFile = Join-Path $backupDir "engram-backup-$timestamp.zip"
    }

    Write-Host "[INFO] Backing up Engram database..." -ForegroundColor Cyan
    Write-Host "  Source: $dbPath" -ForegroundColor Gray

    $dbDir = Split-Path -Parent $dbPath
    $files = Get-ChildItem -Path $dbDir -Filter "*.db" -ErrorAction SilentlyContinue

    if ($files.Count -eq 0) {
        Write-Host "[ERROR] No database files found" -ForegroundColor Red
        return
    }

    try {
        Compress-Archive -Path "$dbDir\*" -DestinationPath $backupFile -Force
        
        $size = (Get-Item $backupFile).Length
        $sizeStr = if ($size -gt 1MB) { "{0:N2} MB" -f ($size / 1MB) } else { "{0:N2} KB" -f ($size / 1KB) }
        
        Write-Host "[SUCCESS] Backup created: $backupFile" -ForegroundColor Green
        Write-Host "  Size: $sizeStr" -ForegroundColor Gray
        
    } catch {
        Write-Host "[ERROR] Backup failed: $_" -ForegroundColor Red
    }
}

function Restore-Engram {
    param([string]$Path)
    
    if (-not $Path) {
        Write-Host "[ERROR] Specify backup file with -BackupPath" -ForegroundColor Red
        return
    }

    if (-not (Test-Path $Path)) {
        Write-Host "[ERROR] Backup file not found: $Path" -ForegroundColor Red
        return
    }

    $dbPath = Get-EngramDbPath
    if (-not $dbPath) {
        Write-Host "[WARN] No existing Engram database, creating default location" -ForegroundColor Yellow
        $dbDir = "$env:USERPROFILE\.engram"
        New-Item -ItemType Directory -Force -Path $dbDir | Out-Null
        $dbPath = "$dbDir\default.db"
    }

    $dbDir = Split-Path -Parent $dbPath

    Write-Host "[INFO] Restoring Engram from: $Path" -ForegroundColor Cyan

    try {
        if (Test-Path $dbDir) {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $preBackup = Join-Path $dbDir "pre-restore-$timestamp"
            Copy-Item -Path $dbDir -Destination $preBackup -Recurse -Force
            Write-Host "  Existing data backed up to: $preBackup" -ForegroundColor Gray
        }

        Expand-Archive -Path $Path -DestinationPath $dbDir -Force
        
        Write-Host "[SUCCESS] Engram restored successfully" -ForegroundColor Green
        Write-Host "  Database location: $dbDir" -ForegroundColor Gray
        
    } catch {
        Write-Host "[ERROR] Restore failed: $_" -ForegroundColor Red
    }
}

function List-Backups {
    $backupDir = Get-BackupDir
    
    $backups = Get-ChildItem -Path $backupDir -Filter "*.zip" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    
    if ($backups.Count -eq 0) {
        Write-Host "No backups found" -ForegroundColor Yellow
        return
    }

    Write-Host "Engram Backups:" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($backup in $backups) {
        $size = if ($backup.Length -gt 1MB) { "{0:N2} MB" -f ($backup.Length / 1MB) } else { "{0:N2} KB" -f ($backup.Length / 1KB) }
        Write-Host "  $($backup.Name) - $size - $($backup.LastWriteTime)" -ForegroundColor White
    }
}

function Show-Stats {
    $dbPath = Get-EngramDbPath
    
    if (-not $dbPath) {
        Write-Host "[ERROR] Engram database not found" -ForegroundColor Red
        return
    }

    $size = (Get-Item $dbPath).Length
    $sizeStr = if ($size -gt 1MB) { "{0:N2} MB" -f ($size / 1MB) } else { "{0:N2} KB" -f ($size / 1KB) }

    Write-Host "Engram Database Stats:" -ForegroundColor Cyan
    Write-Host "  Location: $dbPath" -ForegroundColor White
    Write-Host "  Size: $sizeStr" -ForegroundColor White
    Write-Host "  Last Modified: $(Get-Item $dbPath | Select-Object -ExpandProperty LastWriteTime)" -ForegroundColor White
}

if ($List) {
    List-Backups
} elseif ($Stats) {
    Show-Stats
} elseif ($Backup) {
    Backup-Engram
} elseif ($Restore) {
    Restore-Engram -Path $BackupPath
} else {
    Write-Host "Usage: .\backup-engram.ps1 [-Backup|-Restore|-List|-Stats] [-BackupPath <path>]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\backup-engram.ps1 -Backup              # Create backup"
    Write-Host "  .\backup-engram.ps1 -List                # List all backups"
    Write-Host "  .\backup-engram.ps1 -Stats               # Show database stats"
    Write-Host "  .\backup-engram.ps1 -Restore -BackupPath ""C:\path\to\backup.zip""  # Restore"
}