# Deploy Bicep using Azure Deployment Stacks
# This script uses Azure CLI to deploy the Bicep template as a deployment stack

param(
    [Parameter(Mandatory = $false)]
    [string]$StackName = "stack-acemgt-prd-usw2-001",
    
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-acemgt-prd-usw2-001"
)

# Set error handling
$ErrorActionPreference = "Stop"

Write-Host "🚀 Deploying Bicep template using Azure Deployment Stacks..." -ForegroundColor Green

try {
    # Check if Azure CLI is installed
    Write-Host "🔐 Checking Azure CLI..." -ForegroundColor Yellow
    $azVersion = az version 2>$null
    if (-not $azVersion) {
        Write-Host "❌ Azure CLI is not installed or not in PATH" -ForegroundColor Red
        Write-Host "Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
        exit 1
    }
    
    # Check if user is logged in
    Write-Host "🔐 Checking Azure CLI authentication..." -ForegroundColor Yellow
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Host "Please log into Azure CLI first using 'az login'" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Authenticated as: $($account.user.name)" -ForegroundColor Green
    Write-Host "✅ Using subscription: $($account.name) ($($account.id))" -ForegroundColor Green
    
    # Deploy the stack
    Write-Host "`n🏗️ Creating deployment stack..." -ForegroundColor Yellow
    Write-Host "Stack Name: $StackName" -ForegroundColor Cyan
    Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Cyan
    
    $deployCommand = @(
        "az", "stack", "group", "create",
        "--name", $StackName,
        "--resource-group", $ResourceGroupName,
        "--template-file", "main.bicep",
        "--parameters", "main.bicepparam",
        "--deny-settings-mode", "none",
        "--action-on-unmanage", "deleteResources"
    )
    
    Write-Host "`n🔨 Running command:" -ForegroundColor Yellow
    Write-Host ($deployCommand -join " ") -ForegroundColor Cyan
    
    # Execute the deployment
    & $deployCommand[0] $deployCommand[1..($deployCommand.Length-1)]
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Deployment stack created successfully!" -ForegroundColor Green
        
        # Display stack information
        Write-Host "`n📋 Stack Information:" -ForegroundColor Green
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        
        try {
            $stackInfo = az stack group show --name $StackName --resource-group $ResourceGroupName 2>$null | ConvertFrom-Json
            if ($stackInfo) {
                Write-Host "Stack Name: $($stackInfo.name)" -ForegroundColor White
                Write-Host "Provisioning State: $($stackInfo.provisioningState)" -ForegroundColor White
                Write-Host "Resource Count: $($stackInfo.resources.Count)" -ForegroundColor White
            }
        } catch {
            Write-Host "Stack created successfully (details unavailable)" -ForegroundColor White
        }
        
        Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Verify deployment in Azure Portal" -ForegroundColor White
        Write-Host "2. Check function app configuration" -ForegroundColor White
        Write-Host "3. Test the Alert_Transformer function" -ForegroundColor White
        
    } else {
        Write-Host "❌ Deployment stack creation failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    
} catch {
    Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}

Write-Host "`n🎯 Bicep deployment stack completed!" -ForegroundColor Green