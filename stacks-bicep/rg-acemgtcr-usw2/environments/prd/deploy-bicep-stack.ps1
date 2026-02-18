# Deploy Azure Container Registry using Azure Deployment Stacks - Production Environment
# This script uses Azure CLI to deploy the Bicep template as a deployment stack

param(
    [Parameter(Mandatory = $false)]
    [string]$StackName = "stack-acemgtcr-prd-usw2-001",
    
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId = "e35cd2cf-a9de-4d2b-9134-8b341286cb5d",
    
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-acemgtcr-prd-usw2-001",
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "West US 2"
)

# Set error handling
$ErrorActionPreference = "Stop"

Write-Host "🐳 Deploying Azure Container Registry using Azure Deployment Stacks..." -ForegroundColor Green

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
    
    # Set the subscription
    Write-Host "🎯 Setting subscription to $SubscriptionId..." -ForegroundColor Yellow
    az account set --subscription $SubscriptionId
    
    # Create resource group if it doesn't exist
    Write-Host "📦 Ensuring resource group exists..." -ForegroundColor Yellow
    az group create --name $ResourceGroupName --location $Location --tags Environment=Production ManagedBy="Azure CLI" CostCenter="510-Infrastructure-Production"
    
    # Deploy the stack
    Write-Host "`n🏗️ Creating deployment stack..." -ForegroundColor Yellow
    Write-Host "Stack Name: $StackName" -ForegroundColor Cyan
    Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Cyan
    
    az stack group create `
        --name $StackName `
        --resource-group $ResourceGroupName `
        --template-file "main.bicep" `
        --parameters "main.bicepparam" `
        --deny-settings-mode "none" `
        --action-on-unmanage "deleteResources" `
        --yes
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Azure Container Registry deployment completed successfully!" -ForegroundColor Green
        Write-Host "📋 Stack Details:" -ForegroundColor Yellow
        az stack group show --name $StackName --resource-group $ResourceGroupName --query "{name:name,provisioningState:provisioningState,resourcesDeployed:resources[?resourceType=='Microsoft.ContainerRegistry/registries'].{name:resourceName,type:resourceType}}" --output table
    } else {
        Write-Host "❌ Deployment failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    
} catch {
    Write-Host "❌ Error during deployment: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}

Write-Host "`n🎯 Azure Container Registry deployment completed!" -ForegroundColor Green