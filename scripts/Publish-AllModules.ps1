# Publish All Bicep Modules to Azure Container Registry
# This script discovers and publishes all modules in the modules directory

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string[]]$RegistryNames = @("acrskpmgtcrdevjpe001", "acrskpmgtcrprdcus001"),
    
    [Parameter(Mandatory = $false)]
    [string]$ModulesPath = "..\modules-bicep",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Publishing All Bicep Modules to ACR(s)" -ForegroundColor Green
Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host "Registries: $($RegistryNames -join ', ')" -ForegroundColor Yellow

# Get script directory and construct paths
$ScriptRoot = $PSScriptRoot
$ModulesRoot = Join-Path -Path $ScriptRoot -ChildPath $ModulesPath | Resolve-Path

if (-not (Test-Path $ModulesRoot)) {
    Write-Error "Modules directory not found: $ModulesRoot"
}

# Find all module directories (containing a .bicep file with the same name as the directory)
$modules = Get-ChildItem -Path $ModulesRoot -Directory | ForEach-Object {
    $moduleName = $_.Name
    $bicepFile = Join-Path -Path $_.FullName -ChildPath "$moduleName.bicep"
    if (Test-Path $bicepFile) {
        [PSCustomObject]@{
            Name = $moduleName
            Path = $_.FullName
            BicepFile = $bicepFile
        }
    }
} | Where-Object { $_ -ne $null }

if ($modules.Count -eq 0) {
    Write-Warning "No modules found in $ModulesRoot"
    return
}

Write-Host "📁 Found $($modules.Count) modules:" -ForegroundColor Cyan
$modules | ForEach-Object { Write-Host "   - $($_.Name)" -ForegroundColor White }

if ($WhatIf) {
    Write-Host "`n🔍 WHATIF MODE - No changes will be made" -ForegroundColor Yellow
    foreach ($RegistryName in $RegistryNames) {
        Write-Host "`nRegistry: $RegistryName" -ForegroundColor Cyan
        $modules | ForEach-Object {
            Write-Host "Would publish: $($_.Name) -> $Version" -ForegroundColor Yellow
        }
    }
    return
}

# Track results per registry
$allResults = @{}
$totalSuccessCount = 0
$totalFailureCount = 0

# Publish each module to each registry
foreach ($RegistryName in $RegistryNames) {
    Write-Host "`n" + "#"*60 -ForegroundColor Magenta
    Write-Host "🏭 Publishing to Registry: $RegistryName" -ForegroundColor Magenta
    Write-Host "#"*60 -ForegroundColor Magenta
    
    $results = @()
    $successCount = 0
    $failureCount = 0
foreach ($module in $modules) {
    Write-Host "`n" + "="*60 -ForegroundColor Blue
    Write-Host "📦 Processing module: $($module.Name)" -ForegroundColor Blue
    Write-Host "="*60 -ForegroundColor Blue
    
    try {
        $publishScript = Join-Path -Path $ScriptRoot -ChildPath "Publish-BicepModule.ps1"
        $publishParams = @{
            ModuleName = $module.Name
            Version = $Version
            RegistryName = $RegistryName
            Force = $Force
        }
        
        & $publishScript @publishParams
        
        $results += [PSCustomObject]@{
            Module = $module.Name
            Status = "Success"
            Version = $Version
            Error = $null
        }
        $successCount++
        
        Write-Host "✅ $($module.Name) published successfully" -ForegroundColor Green
        
    } catch {
        $results += [PSCustomObject]@{
            Module = $module.Name
            Status = "Failed"
            Version = $Version
            Error = $_.Exception.Message
        }
        $failureCount++
        
        Write-Host "❌ Failed to publish $($module.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

    $allResults[$RegistryName] = $results
    $totalSuccessCount += $successCount
    $totalFailureCount += $failureCount
    
    Write-Host "`n📊 Registry $RegistryName Summary: $successCount succeeded, $failureCount failed" -ForegroundColor $(if ($failureCount -gt 0) { 'Yellow' } else { 'Green' })
}

# Summary
Write-Host "`n" + "="*60 -ForegroundColor Green
Write-Host "📊 PUBLICATION SUMMARY" -ForegroundColor Green
Write-Host "="*60 -ForegroundColor Green

Write-Host "Total Registries: $($RegistryNames.Count)" -ForegroundColor White
Write-Host "Total Module Publications: $($modules.Count * $RegistryNames.Count)" -ForegroundColor White
Write-Host "Successful: $totalSuccessCount" -ForegroundColor Green
Write-Host "Failed: $totalFailureCount" -ForegroundColor $(if ($totalFailureCount -gt 0) { 'Red' } else { 'Green' })

Write-Host "`n📋 Detailed Results:" -ForegroundColor Yellow
foreach ($RegistryName in $RegistryNames) {
    Write-Host "`n  Registry: $RegistryName" -ForegroundColor Cyan
    $allResults[$RegistryName] | Format-Table -Property Module, Status, Version, Error -AutoSize
}

if ($totalFailureCount -gt 0) {
    Write-Host "⚠️  Some modules failed to publish. Check the errors above." -ForegroundColor Red
    exit 1
} else {
    Write-Host "🎉 All modules published successfully to all registries!" -ForegroundColor Green
}

# Show final ACR status for each registry
foreach ($RegistryName in $RegistryNames) {
    Write-Host "`n📊 Current ACR Module Status for $RegistryName`:" -ForegroundColor Yellow
    try {
        az acr repository list --name $RegistryName --output table
    } catch {
        Write-Warning "Could not retrieve ACR repository list for $RegistryName"
    }
}