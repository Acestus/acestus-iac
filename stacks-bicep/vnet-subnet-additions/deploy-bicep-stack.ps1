# Deploy VNet Subnet Additions

param(
    [string]$SubscriptionId = "7c486f82-99db-43fe-9858-78ae54a74f3b",
    [string]$ResourceGroupName = "rg-transit-conn-weu",
    [string]$ParameterFile = "main.bicepparam",
    [string]$Location = "West Europe"
)

Write-Host "=== Deploying VNet Subnet Additions ===" -ForegroundColor Cyan

# Set subscription context
Write-Host "Setting subscription context to: $SubscriptionId" -ForegroundColor Yellow
az account set --subscription $SubscriptionId

# Deploy the Bicep template
Write-Host "Deploying subnet additions to VNet..." -ForegroundColor Yellow
$deploymentName = "subnet-additions-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

$deployResult = az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file "main.bicep" `
    --parameters $ParameterFile `
    --name $deploymentName `
    --verbose

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Subnet additions deployed successfully!" -ForegroundColor Green
    
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