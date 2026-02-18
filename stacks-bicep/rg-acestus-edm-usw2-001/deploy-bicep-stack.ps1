# Deploy Bicep using Azure Deployment Stacks - Enterprise Data Management Subscription
# This script uses Azure CLI to deploy the Bicep template as a deployment stack at resource group level

param(
    [Parameter(Mandatory = $false)]
    [string]$StackName = "stack-edm-usw2-001",
    
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId = "8b67b073-f765-482f-82ad-ede639aef462",
    
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-acestus-edm-usw2-001",
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "West US 2"
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
    Write-Host "✅ Current subscription: $($account.name) ($($account.id))" -ForegroundColor Green
    
    # Set the target subscription
    Write-Host "`n🎯 Setting target subscription..." -ForegroundColor Yellow
    Write-Host "Target Subscription ID: $SubscriptionId" -ForegroundColor Cyan
    
    $setSubscriptionResult = az account set --subscription $SubscriptionId 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to set subscription: $setSubscriptionResult" -ForegroundColor Red
        exit 1
    }
    
    # Verify subscription switch
    $currentAccount = az account show 2>$null | ConvertFrom-Json
    if ($currentAccount.id -ne $SubscriptionId) {
        Write-Host "❌ Failed to switch to target subscription. Current: $($currentAccount.id), Expected: $SubscriptionId" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Successfully switched to: $($currentAccount.name) ($($currentAccount.id))" -ForegroundColor Green
    
    # Create resource group if it doesn't exist
    Write-Host "`n📁 Creating resource group..." -ForegroundColor Yellow
    Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Cyan
    Write-Host "Location: $Location" -ForegroundColor Cyan
    
    $createRgResult = az group create --name $ResourceGroupName --location $Location --tags "Environment=Production" "ManagedBy=https://github.com/<your-org>/<your-repo>" "CostCenter=530-EnterpriseDataManagement-Production" "Department=530-EnterpriseDataManagement" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to create resource group: $createRgResult" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Resource group ready" -ForegroundColor Green
    
    # Deploy the stack at resource group level
    Write-Host "`n🏗️ Creating resource group-level deployment stack..." -ForegroundColor Yellow
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