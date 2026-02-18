# Publish All Terraform Modules to Azure Container Registry
# This script publishes all Terraform modules in the modules directory to ACR

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string]$RegistryName = "acracemgtcrdevusw2001",
    
    [Parameter(Mandatory = $false)]
    [string]$ModulePrefix = "terraform/modules",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Publishing All Terraform Modules to ACR" -ForegroundColor Green
Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host "Registry: $RegistryName" -ForegroundColor Yellow

# Validate inputs
if ($Version -notmatch '^v?\d+\.\d+\.\d+$') {
    Write-Error "Version must be in format vX.Y.Z or X.Y.Z (e.g., v1.0.0 or 1.0.0)"
}

# Normalize version
$TagVersion = $Version -replace '^v', ''

# Get all module directories
$ScriptRoot = $PSScriptRoot
$moduleDirectories = Get-ChildItem -Path $ScriptRoot -Directory | Where-Object { 
    # Module directories should contain main.tf
    Test-Path (Join-Path $_.FullName "main.tf")
}

if ($moduleDirectories.Count -eq 0) {
    Write-Error "No Terraform modules found in $ScriptRoot"
}

Write-Host "`n📦 Found $($moduleDirectories.Count) modules to publish:" -ForegroundColor Cyan
$moduleDirectories | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }

# Check if oras is available
$orasAvailable = $null -ne (Get-Command oras -ErrorAction SilentlyContinue)
if (-not $orasAvailable) {
    Write-Error "ORAS CLI is required. Install with: winget install oras"
}

# Login to ACR and get token for ORAS
$loginServer = "$RegistryName.azurecr.io"
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

# Track results
$results = @{
    Success = @()
    Failed = @()
    Skipped = @()
}

# Publish each module
foreach ($module in $moduleDirectories) {
    $moduleName = $module.Name
    $modulePath = $module.FullName
    $target = "$RegistryName.azurecr.io/$ModulePrefix/$moduleName`:$TagVersion"
    
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "📦 Processing: $moduleName" -ForegroundColor Yellow
    
    if ($WhatIf) {
        Write-Host "  WHATIF: Would publish to $target" -ForegroundColor DarkYellow
        $results.Skipped += $moduleName
        continue
    }
    
    try {
        # Check if version exists (unless Force)
        if (-not $Force) {
            $existingTags = az acr repository show-tags --name $RegistryName --repository "$ModulePrefix/$moduleName" 2>$null | ConvertFrom-Json
            if ($existingTags -contains $TagVersion) {
                Write-Host "  ⚠️ Version $TagVersion already exists. Use -Force to overwrite." -ForegroundColor Yellow
                $results.Skipped += $moduleName
                continue
            }
        }
        
        # Create archive
        $tempDir = [System.IO.Path]::GetTempPath()
        $archivePath = Join-Path -Path $tempDir -ChildPath "$moduleName.tar.gz"
        
        Push-Location $modulePath
        try {
            tar -czf $archivePath . 2>&1 | Out-Null
        }
        finally {
            Pop-Location
        }
        
        # Push using ORAS (with --disable-path-validation for Windows absolute paths)
        $pushResult = oras push $target $archivePath --disable-path-validation 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Published successfully" -ForegroundColor Green
            $results.Success += $moduleName
        }
        else {
            throw $pushResult
        }
        
        # Cleanup
        if (Test-Path $archivePath) {
            Remove-Item $archivePath -Force
        }
    }
    catch {
        Write-Host "  ❌ Failed: $_" -ForegroundColor Red
        $results.Failed += $moduleName
    }
}

# Summary
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 PUBLISHING SUMMARY" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "✅ Success: $($results.Success.Count)" -ForegroundColor Green
Write-Host "⚠️ Skipped: $($results.Skipped.Count)" -ForegroundColor Yellow
Write-Host "❌ Failed:  $($results.Failed.Count)" -ForegroundColor Red

if ($results.Failed.Count -gt 0) {
    Write-Host "`nFailed modules:" -ForegroundColor Red
    $results.Failed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

Write-Host "`n✅ Publishing complete!" -ForegroundColor Green
