# Publish Terraform Module to Azure Container Registry
# This script publishes a single Terraform module to the Acestus ACR using ORAS

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ModuleName,
    
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string]$RegistryName = "acracemgtcrdevusw2001",
    
    [Parameter(Mandatory = $false)]
    [string]$ModulePrefix = "terraform/modules",
    
    [Parameter(Mandatory = $false)]
    [string]$ModulesPath = ".",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Publishing Terraform Module to ACR" -ForegroundColor Green
Write-Host "Module: $ModuleName" -ForegroundColor Yellow
Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host "Registry: $RegistryName" -ForegroundColor Yellow

# Validate inputs
if ($Version -notmatch '^v?\d+\.\d+\.\d+$') {
    Write-Error "Version must be in format vX.Y.Z or X.Y.Z (e.g., v1.0.0 or 1.0.0)"
}

# Normalize version (remove 'v' prefix for ACR tag if present)
$TagVersion = $Version -replace '^v', ''

# Get script directory and construct paths
$ScriptRoot = $PSScriptRoot
$ModulePath = if ($ModulesPath -eq ".") { Join-Path -Path $ScriptRoot -ChildPath $ModuleName } else { Join-Path -Path $ScriptRoot -ChildPath "$ModulesPath\$ModuleName" }

# Validate module exists
if (-not (Test-Path $ModulePath)) {
    Write-Error "Module directory not found: $ModulePath"
}

# Validate required files exist
$requiredFiles = @("main.tf", "variables.tf", "outputs.tf", "versions.tf")
foreach ($file in $requiredFiles) {
    $filePath = Join-Path -Path $ModulePath -ChildPath $file
    if (-not (Test-Path $filePath)) {
        Write-Error "Required file not found: $filePath"
    }
}

Write-Host "📁 Module Path: $ModulePath" -ForegroundColor Cyan

# Target reference
$loginServer = "$RegistryName.azurecr.io"
$target = "$loginServer/$ModulePrefix/$ModuleName`:$TagVersion"

# Check if we're in WhatIf mode
if ($WhatIf) {
    Write-Host "🔍 WHATIF MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host "Would publish module from: $ModulePath"
    Write-Host "To target: $target"
    exit 0
}

# Check if oras is available
$orasAvailable = $null -ne (Get-Command oras -ErrorAction SilentlyContinue)
if (-not $orasAvailable) {
    Write-Error "ORAS CLI is required. Install with: winget install oras"
}

# Login to ACR and get token for ORAS
Write-Host "`n🔑 Authenticating to ACR..." -ForegroundColor Cyan
try {
    $tokenOutput = az acr login --name $RegistryName --expose-token 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to get ACR token: $tokenOutput"
    }
    $acrLogin = $tokenOutput | ConvertFrom-Json
    $accessToken = $acrLogin.accessToken
    
    # Login ORAS using the token
    $accessToken | oras login $loginServer --username 00000000-0000-0000-0000-000000000000 --password-stdin 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to login ORAS to ACR"
    }
    Write-Host "✅ Authenticated to $RegistryName" -ForegroundColor Green
}
catch {
    Write-Error "Failed to authenticate to ACR: $_"
}

# Check if version already exists (unless Force is specified)
if (-not $Force) {
    Write-Host "`n🔍 Checking if version already exists..." -ForegroundColor Cyan
    $existingTags = az acr repository show-tags --name $RegistryName --repository "$ModulePrefix/$ModuleName" 2>$null | ConvertFrom-Json
    if ($existingTags -contains $TagVersion) {
        Write-Error "Version $TagVersion already exists for $ModuleName. Use -Force to overwrite."
    }
    Write-Host "✅ Version check passed" -ForegroundColor Green
}

# Create temporary archive
Write-Host "`n📦 Creating module archive..." -ForegroundColor Cyan
$tempDir = [System.IO.Path]::GetTempPath()
$archivePath = Join-Path -Path $tempDir -ChildPath "$ModuleName.tar.gz"

# Create tar.gz archive
Push-Location $ModulePath
try {
    tar -czf $archivePath .
    Write-Host "✅ Created archive: $archivePath" -ForegroundColor Green
}
finally {
    Pop-Location
}

# Push to ACR using ORAS
Write-Host "`n🚀 Pushing module to ACR..." -ForegroundColor Cyan
Write-Host "Target: $target" -ForegroundColor Cyan
try {
    $pushOutput = oras push $target $archivePath --disable-path-validation 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ORAS push failed: $pushOutput"
    }
    Write-Host $pushOutput
    Write-Host "✅ Successfully published $ModuleName`:$TagVersion" -ForegroundColor Green
}
catch {
    Write-Error "Failed to push module: $_"
}
finally {
    # Cleanup
    if (Test-Path $archivePath) {
        Remove-Item $archivePath -Force
    }
}

# Verify the upload
Write-Host "`n📋 Verifying upload..." -ForegroundColor Cyan
$verifyTags = az acr repository show-tags --name $RegistryName --repository "$ModulePrefix/$ModuleName" -o tsv 2>$null
if ($verifyTags -match $TagVersion) {
    Write-Host "✅ Verified: $target" -ForegroundColor Green
}
else {
    Write-Warning "Could not verify upload. Check ACR manually."
}

Write-Host "`n🎉 Module $ModuleName $TagVersion published successfully to $RegistryName!" -ForegroundColor Green
