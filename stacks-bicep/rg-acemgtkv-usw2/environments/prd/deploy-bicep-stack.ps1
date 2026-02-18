# Deploy Key Vault Production

param(
    [string]$SubscriptionId = "7c486f82-99db-43fe-9858-78ae54a74f3b",
    [string]$ResourceGroupName = "rg-acemgtkv-prd-usw2-001",
    [string]$ParameterFile = "main.bicepparam",
    [string]$Location = "West US 2"
)

Write-Host "=== Deploying Key Vault Production Stack ===" -ForegroundColor Cyan

# Set subscription context
Write-Host "Setting subscription context to: $SubscriptionId" -ForegroundColor Yellow
az account set --subscription $SubscriptionId

# Check if resource group exists, create if not
$rgExists = az group show --name $ResourceGroupName --query "name" -o tsv 2>$null
if (-not $rgExists) {
    Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
    az group create --name $ResourceGroupName --location $Location
} else {
    Write-Host "Resource group already exists: $ResourceGroupName" -ForegroundColor Green
}

# Deploy the Bicep template
Write-Host "Deploying Key Vault resources..." -ForegroundColor Yellow
$deploymentName = "keyvault-prod-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

$deployResult = az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file "main.bicep" `
    --parameters $ParameterFile `
    --name $deploymentName `
    --verbose

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Key Vault production stack deployed successfully!" -ForegroundColor Green
    
    # Display outputs
    Write-Host "`n=== Deployment Outputs ===" -ForegroundColor Cyan
    $outputs = $deployResult | ConvertFrom-Json
    if ($outputs.properties.outputs) {
        $outputs.properties.outputs | ConvertTo-Json -Depth 3
    }
} else {
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Deployment Complete ===" -ForegroundColor Cyan