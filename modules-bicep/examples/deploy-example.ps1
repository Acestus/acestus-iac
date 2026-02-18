# Deploy Example Using Custom Storage Account Module
# This script demonstrates how to deploy templates that use custom ACR modules

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-example-custom-modules-dev-usw2",
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "West US 2",
    
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId = "8a0d1fba-54d6-4f26-86a9-04aa58ba7fb0", # Your sandbox subscription
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Deploying Example with Custom Storage Module" -ForegroundColor Green

# Get script directory
$ScriptRoot = $PSScriptRoot
$TemplateFile = Join-Path -Path $ScriptRoot -ChildPath "example-using-custom-storage.bicep"
$ParameterFile = Join-Path -Path $ScriptRoot -ChildPath "example-using-custom-storage.bicepparam"

try {
    # Set context
    Write-Host "🔑 Setting Azure context..." -ForegroundColor Cyan
    az account set --subscription $SubscriptionId
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to set subscription context"
    }

    # Create resource group
    Write-Host "📁 Creating resource group..." -ForegroundColor Cyan
    az group create --name $ResourceGroupName --location $Location --output table
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create resource group"
    }

    # Login to ACR (required for module access)
    Write-Host "🐳 Logging into ACR..." -ForegroundColor Cyan
    az acr login --name acrskpmgtcrprdusw2001
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to login to ACR. Check ACR access permissions."
    }

    if ($WhatIf) {
        Write-Host "🔍 Running what-if analysis..." -ForegroundColor Yellow
        az deployment group what-if `
            --resource-group $ResourceGroupName `
            --template-file $TemplateFile `
            --parameters $ParameterFile `
            --output table
    } else {
        # Deploy
        Write-Host "🚀 Deploying template..." -ForegroundColor Cyan
        $deploymentName = "custom-module-example-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        
        az deployment group create `
            --resource-group $ResourceGroupName `
            --template-file $TemplateFile `
            --parameters $ParameterFile `
            --name $deploymentName `
            --output table

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
            
            # Show outputs
            Write-Host "`n📋 Deployment Outputs:" -ForegroundColor Yellow
            az deployment group show `
                --resource-group $ResourceGroupName `
                --name $deploymentName `
                --query "properties.outputs" `
                --output table

            # List created resources
            Write-Host "`n📊 Created Resources:" -ForegroundColor Yellow
            az resource list --resource-group $ResourceGroupName --output table
        } else {
            Write-Error "Deployment failed"
        }
    }

    Write-Host "`n🎉 Example deployment completed!" -ForegroundColor Green
    Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor White
    
    if (-not $WhatIf) {
        Write-Host "`n💡 To clean up resources:" -ForegroundColor Yellow
        Write-Host "az group delete --name $ResourceGroupName --yes" -ForegroundColor White
    }

} catch {
    Write-Host "❌ Error during deployment: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}