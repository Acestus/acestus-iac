<#
.SYNOPSIS
    Updates AVM module versions in Terraform files using the latest versions from terraform-avm-versions.csv.

.PARAMETER Preview
    Shows what changes would be made without actually making them.

.PARAMETER UseExactVersion
    When set, updates to exact versions (0.5.1). Default uses pessimistic constraint (~> 0.5).

.EXAMPLE
    .\Update-TerraformAvmVersions.ps1 -Preview

.EXAMPLE
    .\Update-TerraformAvmVersions.ps1

.EXAMPLE
    .\Update-TerraformAvmVersions.ps1 -UseExactVersion
#>

param(
    [string]$CsvPath = "$PSScriptRoot\..\modules-terraform\terraform-avm-versions.csv",
    [string]$SearchPath = "$PSScriptRoot\..",
    [switch]$Preview,
    [switch]$UseExactVersion
)

Write-Host "Reading Terraform AVM versions from CSV..." -ForegroundColor Cyan

# Import CSV and build version map
$versionMap = @{}
Import-Csv -Path $CsvPath | ForEach-Object {
    $versionMap[$_.Module] = $_.Version
}

Write-Host "Found $($versionMap.Count) Terraform AVM modules" -ForegroundColor Green

# Find all Terraform files
Write-Host "`nSearching Terraform files..." -ForegroundColor Cyan
$tfFiles = Get-ChildItem -Path $SearchPath -Filter "*.tf" -Recurse
$totalUpdates = 0
$updatedFiles = @()

foreach ($file in $tfFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    $fileChanged = $false
    
    # Find all AVM module sources and their version lines
    # Pattern: source = "Azure/avm-res-xxx/azurerm" followed by version = "..."
    foreach ($module in $versionMap.Keys) {
        # Match source line for this module
        $sourcePattern = "source\s*=\s*`"Azure/$module/azurerm`""
        
        if ($content -match $sourcePattern) {
            $latestVersion = $versionMap[$module]
            $majorMinor = ($latestVersion -split '\.')[0..1] -join '.'
            
            # Determine new version string
            if ($UseExactVersion) {
                $newVersionValue = $latestVersion
            } else {
                $newVersionValue = "~> $majorMinor"
            }
            
            # Pattern to find version line after source (within same module block)
            # This regex finds version = "anything" that comes after the source line
            $versionPattern = "(?<=$sourcePattern[\s\S]*?)version\s*=\s*`"[^`"]+`""
            
            if ($content -match $versionPattern) {
                $currentMatch = $Matches[0]
                $currentVersion = if ($currentMatch -match '`"([^`"]+)`"') { $Matches[1] } else { "unknown" }
                
                # Skip if already at latest
                if ($currentVersion -eq $newVersionValue -or $currentVersion -eq $latestVersion) {
                    continue
                }
                
                # Create the new version line
                $newVersionLine = "version = `"$newVersionValue`""
                
                # Replace the version line
                $content = $content -replace $versionPattern, $newVersionLine
                
                if ($content -ne $originalContent -and -not $fileChanged) {
                    Write-Host "  $($file.Name): $module $currentVersion -> $newVersionValue" -ForegroundColor Yellow
                    $fileChanged = $true
                    $totalUpdates++
                }
            }
        }
    }
    
    if ($fileChanged) {
        $updatedFiles += $file.FullName
        if (-not $Preview) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "  Updated: $($file.FullName)" -ForegroundColor Green
        }
    }
}

Write-Host "`nSummary: $($updatedFiles.Count) files, $totalUpdates updates" -ForegroundColor Cyan
if ($Preview -and $totalUpdates -gt 0) {
    Write-Host "Run without -Preview to apply changes." -ForegroundColor Yellow
}
