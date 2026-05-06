<#
.SYNOPSIS
Copies the local module source to the installed PowerShell Universal module folder.

.DESCRIPTION
This helper copies the contents of the local module source (src\PowerShellUniversal.Apps.Bookworm)
to the installed module location (default: C:\ProgramData\UniversalAutomation\Repository\Modules\PowerShellUniversal.Apps.Bookworm).
Optionally restarts the PowerShell Universal service so the running runspace picks up updated function signatures.

.PARAMETER SourcePath
Path to the local module source. Defaults to the module folder in this repository.

.PARAMETER TargetModulePath
Path to the installed module folder (default: ProgramData path used by the installer).

.PARAMETER RestartService
If specified, attempt to restart the Windows service named by ServiceName.

.PARAMETER ServiceName
Name of the Windows service for PowerShell Universal. Default: 'UniversalAutomation'

.EXAMPLE
.\Sync-InstalledModule.ps1 -RestartService
Copies files to the installed module path and restarts the PowerShell Universal service.
#>

param(
    [string]$SourcePath = (Join-Path $PSScriptRoot 'PowerShellUniversal.StandardLibrary'),
    [string]$TargetModulePath = 'C:\ProgramData\UniversalAutomation\Repository\Modules\PowerShellUniversal.StandardLibrary',
    [switch]$RestartService,
    [string]$ServiceName = 'PowerShellUniversal'
)

if (-not (Test-Path $SourcePath)) {
    Write-Error "Source module path not found: $SourcePath"
    exit 1
}

Write-Host "Syncing module from $SourcePath to $TargetModulePath" -ForegroundColor Cyan

if (-not (Test-Path $TargetModulePath)) {
    Write-Host "Target module path does not exist. Creating: $TargetModulePath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $TargetModulePath -Force | Out-Null
}

try {
    Copy-Item -Path (Join-Path $SourcePath '*') -Destination $TargetModulePath -Recurse -Force
    Write-Host "✓ Module files copied successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to copy module files: $($_.Exception.Message)"
    exit 1
}

if ($RestartService) {
    $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if (-not $svc) {
        Write-Host "Service '$ServiceName' not found. Please restart your PowerShell Universal service manually." -ForegroundColor Yellow
    }
    else {
        Write-Host "Restarting service '$ServiceName'..." -ForegroundColor Yellow
        try {
            Restart-Service -Name $ServiceName -Force -ErrorAction Stop
            Write-Host "✓ Service restarted." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to restart service: $($_.Exception.Message)"
            Write-Host "Please restart manually: Restart-Service -Name '$ServiceName' -Force" -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "Note: You must restart PowerShell Universal (or re-import the module in the dashboard runspace) to pick up updated function signatures." -ForegroundColor Yellow
}

Clear-Host