# Publish Bicep Module to Azure Container Registry
# This script publishes a single Bicep module to the Acestus ACR with proper versioning and validation

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ModuleName,
    
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string]$RegistryName = "acrskpmgtcrdevusw2001",
    
    [Parameter(Mandatory = $false)]
    [string]$ModulePrefix = "bicep/modules",
    
    [Parameter(Mandatory = $false)]
    [string]$ModulesPath = ".",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Publishing Bicep Module to ACR" -ForegroundColor Green
Write-Host "Module: $ModuleName" -ForegroundColor Yellow
Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host "Registry: $RegistryName" -ForegroundColor Yellow

# Validate inputs
if ($Version -notmatch '^v\d+\.\d+\.\d+$') {
    Write-Error "Version must be in format vX.Y.Z (e.g., v1.0.0)"
}

# Get script directory and construct paths
$ScriptRoot = $PSScriptRoot
$ModulePath = if ($ModulesPath -eq ".") { Join-Path -Path $ScriptRoot -ChildPath $ModuleName } else { Join-Path -Path $ScriptRoot -ChildPath "$ModulesPath\$ModuleName" }
$BicepFile = Join-Path -Path $ModulePath -ChildPath "$ModuleName.bicep"

# Validate module exists
if (-not (Test-Path $ModulePath)) {
    Write-Error "Module directory not found: $ModulePath"
}

if (-not (Test-Path $BicepFile)) {
    Write-Error "Bicep file not found: $BicepFile"
}

Write-Host "📁 Module Path: $ModulePath" -ForegroundColor Cyan

# Check if we're in WhatIf mode
if ($WhatIf) {
    Write-Host "🔍 WHATIF MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host "Would publish: $BicepFile"
    Write-Host "To target: br:$RegistryName.azurecr.io/$ModulePrefix/$ModuleName`:$Version"
    return
}

try {
    # Test Azure CLI connectivity
    Write-Host "🔑 Checking Azure CLI authentication..." -ForegroundColor Cyan
    $currentUser = az account show --query "user.name" -o tsv 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Azure CLI not authenticated. Please run 'az login'"
    }
    Write-Host "✅ Authenticated as: $currentUser" -ForegroundColor Green

    # Check ACR access (using repository list which requires less privileges than acr show)
    Write-Host "🐳 Checking ACR access..." -ForegroundColor Cyan
    $acrCheck = az acr repository list --name $RegistryName --output tsv 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Cannot access ACR '$RegistryName'. Check permissions and registry name."
    }
    Write-Host "✅ ACR access confirmed: $RegistryName" -ForegroundColor Green

    # Validate Bicep syntax
    Write-Host "🧪 Validating Bicep syntax..." -ForegroundColor Cyan
    az bicep build --file $BicepFile --stdout | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Bicep file has syntax errors. Please fix before publishing."
    }
    Write-Host "✅ Bicep syntax validation passed" -ForegroundColor Green

    # Check if version already exists (unless Force is specified)
    if (-not $Force) {
        Write-Host "🔍 Checking if version already exists..." -ForegroundColor Cyan
        $existingVersions = az acr repository show-tags --name $RegistryName --repository "$ModulePrefix/$ModuleName" --output tsv 2>$null
        if ($LASTEXITCODE -eq 0 -and $existingVersions -contains $Version) {
            Write-Error "Version $Version already exists for module $ModuleName. Use -Force to overwrite."
        }
        Write-Host "✅ Version check passed" -ForegroundColor Green
    }

    # Publish module (az bicep publish handles authentication via Azure CLI)
    $targetReference = "br:$RegistryName.azurecr.io/$ModulePrefix/$ModuleName`:$Version"
    Write-Host "📤 Publishing module..." -ForegroundColor Cyan
    Write-Host "Target: $targetReference" -ForegroundColor Yellow
    
    az bicep publish --file $BicepFile --target $targetReference
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to publish module"
    }

    Write-Host "✅ Module published successfully!" -ForegroundColor Green
    Write-Host "📋 Module Details:" -ForegroundColor Yellow
    Write-Host "   Name: $ModuleName"
    Write-Host "   Version: $Version"
    Write-Host "   Reference: $targetReference"
    
    # Show repository info (non-critical, wrapped in try-catch)
    Write-Host "📊 Repository Status:" -ForegroundColor Yellow
    try {
        az acr repository show-tags --name $RegistryName --repository "$ModulePrefix/$ModuleName" --orderby time_desc --top 5 --output table 2>$null
    } catch {
        Write-Host "   (Unable to retrieve tag details)" -ForegroundColor Gray
    }

    Write-Host "`n🎉 Module $ModuleName $Version published successfully to $RegistryName!" -ForegroundColor Green

} catch {
    Write-Host "❌ Error during module publishing: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}