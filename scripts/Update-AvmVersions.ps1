<#
.SYNOPSIS
    Updates AVM module versions in Bicep files using the latest versions from avm-versions.csv.

.PARAMETER Preview
    Shows what changes would be made without actually making them.

.EXAMPLE
    .\Update-AvmVersions.ps1 -Preview

.EXAMPLE
    .\Update-AvmVersions.ps1
#>

param(
    [string]$CsvPath = "$PSScriptRoot\..\modules-bicep\avm-versions.csv",
    [string]$SearchPath = "$PSScriptRoot\..",
    [switch]$Preview
)

Write-Host "Reading AVM versions from CSV..." -ForegroundColor Cyan

# Import CSV
$versionMap = @{}
Import-Csv -Path $CsvPath | ForEach-Object {
    $versionMap[$_.Module] = $_.Version
}

Write-Host "Found $($versionMap.Count) AVM modules" -ForegroundColor Green

# Find all Bicep files
Write-Host "`nSearching Bicep files..." -ForegroundColor Cyan
$bicepFiles = Get-ChildItem -Path $SearchPath -Filter "*.bicep" -Recurse
$totalUpdates = 0
$updatedFiles = @()

foreach ($file in $bicepFiles) {
    $lines = Get-Content -Path $file.FullName
    $newLines = @()
    $fileChanged = $false
    
    foreach ($line in $lines) {
        $newLine = $line
        if ($line -match "'br/public:(avm/res/[^:]+):(\d+\.\d+\.\d+)'") {
            $modulePath = $Matches[1]
            $currentVersion = $Matches[2]
            
            if ($versionMap.ContainsKey($modulePath) -and $currentVersion -ne $versionMap[$modulePath]) {
                $latestVersion = $versionMap[$modulePath]
                $newLine = $line -replace ":$currentVersion'", ":$latestVersion'"
                Write-Host "  $($file.Name): $modulePath $currentVersion -> $latestVersion" -ForegroundColor Yellow
                $fileChanged = $true
                $totalUpdates++
            }
        }
        $newLines += $newLine
    }
    
    if ($fileChanged) {
        $updatedFiles += $file.FullName
        if (-not $Preview) {
            Set-Content -Path $file.FullName -Value $newLines
            Write-Host "  Updated: $($file.FullName)" -ForegroundColor Green
        }
    }
}

Write-Host "`nSummary: $($updatedFiles.Count) files, $totalUpdates updates" -ForegroundColor Cyan
if ($Preview -and $totalUpdates -gt 0) {
    Write-Host "Run without -Preview to apply changes." -ForegroundColor Yellow
}
