# Universal Bicep Deployment Script
# Auto-detects resource group name and stack name from current directory
# 
# Usage: Place this script in any rg-* folder and run it
# It will automatically determine the correct names from the folder name

param(
    [string]$Subscription,  # Will auto-detect if not provided
    [switch]$WhatIf,
    [switch]$Verbose
)

# Auto-detect values from current directory name
$FolderName = Split-Path -Leaf $PSScriptRoot
$ResourceGroupName = $FolderName
$StackName = $FolderName -replace '^rg-', 'stack-'

# Auto-detect subscription from bicepparam if not provided
if (-not $Subscription) {
    $ParamFile = Join-Path $PSScriptRoot "main.bicepparam"
    if (Test-Path $ParamFile) {
        $ParamContent = Get-Content $ParamFile -Raw
        if ($ParamContent -match "Subscription:\s*'([^']+)'") {
            $Subscription = $matches[1]
            Write-Host "📄 Auto-detected subscription from bicepparam: $Subscription" -ForegroundColor Magenta
        }
    }
    
    # Fallback if not found in bicepparam
    if (-not $Subscription) {
        $Subscription = "Corp-710-Analytics"
        Write-Host "⚠️  Using fallback subscription: $Subscription" -ForegroundColor Yellow
    }
}

# Validate we're in a resource group folder
if (-not $FolderName.StartsWith('rg-')) {
    Write-Error "This script must be run from a resource group folder (starts with 'rg-')"
    exit 1
}

# Check for required files
$BicepFile = Join-Path $PSScriptRoot "main.bicep"
$ParamFile = Join-Path $PSScriptRoot "main.bicepparam"

if (-not (Test-Path $BicepFile)) {
    Write-Error "main.bicep file not found in $PSScriptRoot"
    exit 1
}

if (-not (Test-Path $ParamFile)) {
    Write-Error "main.bicepparam file not found in $PSScriptRoot"
    exit 1
}

# Display deployment info
Write-Host "🚀 Bicep Deployment" -ForegroundColor Blue
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Green
Write-Host "Stack Name: $StackName" -ForegroundColor Cyan
Write-Host "Subscription: $Subscription" -ForegroundColor Yellow
Write-Host "Bicep File: $BicepFile" -ForegroundColor Gray
Write-Host "Parameters: $ParamFile" -ForegroundColor Gray

if ($WhatIf) {
    Write-Host "⚠️  WhatIf mode - no actual deployment" -ForegroundColor Yellow
}

Write-Host ""

try {
    # Ensure we're in the correct directory
    Set-Location $PSScriptRoot
    
    # Set Azure context
    Write-Host "Setting Azure context..." -ForegroundColor Cyan
    Set-AzContext -Subscription $Subscription | Out-Null
    
    # Deploy the stack
    $deployParams = @{
        Name                    = $StackName
        ResourceGroupName       = $ResourceGroupName
        TemplateFile           = "main.bicep"
        TemplateParameterFile  = "main.bicepparam"
        DenySettingsMode       = "None"
        ActionOnUnmanage       = "DeleteResources"
    }
    
    if ($WhatIf) {
        $deployParams.Add("WhatIf", $true)
    }
    
    if ($Verbose) {
        $deployParams.Add("Verbose", $true)
    }
    
    Write-Host "Starting deployment..." -ForegroundColor Cyan
    $result = New-AzResourceGroupDeploymentStack @deployParams
    
    Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    
    if ($result.Outputs) {
        Write-Host ""
        Write-Host "📋 Deployment Outputs:" -ForegroundColor Blue
        $result.Outputs | ConvertTo-Json -Depth 3 | Write-Host
    }
}
catch {
    Write-Host "❌ Deployment failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}