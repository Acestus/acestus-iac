# Deploy Aspire Dashboard for Production Environment
# This script deploys the .NET Aspire Dashboard infrastructure to the production environment

param(
    [string]$SubscriptionId = $env:AZURE_SUBSCRIPTION_ID,
    [string]$ResourceGroupName = "rg-aspire-prd-eus2-001",
    [string]$Location = "West US 2",
    [switch]$WhatIf,
    [switch]$Force
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Function to write colored output
function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

try {
    Write-ColoredOutput "Starting Aspire Dashboard deployment for Production environment..." "Green"
    
    # Check if logged into Azure
    $context = Get-AzContext
    if (-not $context) {
        Write-ColoredOutput "Not logged into Azure. Please run 'Connect-AzAccount' first." "Red"
        exit 1
    }
    
    # Set subscription context if provided
    if ($SubscriptionId) {
        Write-ColoredOutput "Setting subscription context to: $SubscriptionId" "Yellow"
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    }
    
    $currentContext = Get-AzContext
    Write-ColoredOutput "Using subscription: $($currentContext.Subscription.Name) ($($currentContext.Subscription.Id))" "Cyan"
    
    # Production deployment confirmation
    Write-ColoredOutput "⚠️  WARNING: This is a PRODUCTION deployment!" "Red"
    Write-ColoredOutput "   Resource Group: $ResourceGroupName" "Yellow"
    Write-ColoredOutput "   Environment: Production" "Yellow"
    
    # Check if resource group exists, create if it doesn't
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-ColoredOutput "Resource group '$ResourceGroupName' does not exist. Creating..." "Yellow"
        $rg = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
        Write-ColoredOutput "Resource group '$ResourceGroupName' created successfully." "Green"
    } else {
        Write-ColoredOutput "Resource group '$ResourceGroupName' already exists." "Cyan"
    }
    
    # Set deployment parameters
    $deploymentName = "aspire-dashboard-prd-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $templateFile = Join-Path $PSScriptRoot "main.bicep"
    $parametersFile = Join-Path $PSScriptRoot "main.bicepparam"
    
    # Validate template files exist
    if (-not (Test-Path $templateFile)) {
        Write-ColoredOutput "Template file not found: $templateFile" "Red"
        exit 1
    }
    
    if (-not (Test-Path $parametersFile)) {
        Write-ColoredOutput "Parameters file not found: $parametersFile" "Red"
        exit 1
    }
    
    Write-ColoredOutput "Deployment Details:" "Yellow"
    Write-ColoredOutput "  Name: $deploymentName" "White"
    Write-ColoredOutput "  Resource Group: $ResourceGroupName" "White"
    Write-ColoredOutput "  Template: $templateFile" "White"
    Write-ColoredOutput "  Parameters: $parametersFile" "White"
    
    # Perform what-if deployment if requested
    if ($WhatIf) {
        Write-ColoredOutput "Performing What-If deployment..." "Yellow"
        $whatIfResult = New-AzResourceGroupDeployment `
            -Name $deploymentName `
            -ResourceGroupName $ResourceGroupName `
            -TemplateParameterFile $parametersFile `
            -WhatIf
        
        Write-ColoredOutput "What-If deployment completed. Review the changes above." "Green"
        return
    }
    
    # Extra confirmation for production deployments unless Force is specified
    if (-not $Force) {
        Write-ColoredOutput "`n🔒 Production Deployment Confirmation Required" "Red"
        $confirmation1 = Read-Host "Type 'PRODUCTION' to confirm this is a production deployment"
        if ($confirmation1 -ne 'PRODUCTION') {
            Write-ColoredOutput "Deployment cancelled. Confirmation text did not match." "Yellow"
            return
        }
        
        $confirmation2 = Read-Host "Proceed with PRODUCTION deployment? (yes/no)"
        if ($confirmation2 -ne 'yes') {
            Write-ColoredOutput "Deployment cancelled by user." "Yellow"
            return
        }
    }
    
    Write-ColoredOutput "Starting production deployment..." "Green"
    
    # Deploy the template
    $deployment = New-AzResourceGroupDeployment `
        -Name $deploymentName `
        -ResourceGroupName $ResourceGroupName `
        -TemplateParameterFile $parametersFile `
        -Verbose
    
    if ($deployment.ProvisioningState -eq "Succeeded") {
        Write-ColoredOutput "Production deployment completed successfully!" "Green"
        
        # Display outputs
        Write-ColoredOutput "`nDeployment Outputs:" "Yellow"
        foreach ($output in $deployment.Outputs.GetEnumerator()) {
            Write-ColoredOutput "  $($output.Key): $($output.Value.Value)" "White"
        }
        
        # Display Aspire Dashboard URL
        if ($deployment.Outputs.aspireDashboardUrl) {
            Write-ColoredOutput "`n🎉 Production Aspire Dashboard is available at:" "Green"
            Write-ColoredOutput "   $($deployment.Outputs.aspireDashboardUrl.Value)" "Cyan"
        }
        
        # Display OTLP endpoint
        if ($deployment.Outputs.otlpEndpointUrl) {
            Write-ColoredOutput "`n📡 Production OTLP Endpoint for telemetry:" "Green"
            Write-ColoredOutput "   $($deployment.Outputs.otlpEndpointUrl.Value)" "Cyan"
        }
        
        Write-ColoredOutput "`n🔐 Note: Production dashboard has authentication enabled." "Yellow"
        
    } else {
        Write-ColoredOutput "Production deployment failed with state: $($deployment.ProvisioningState)" "Red"
        exit 1
    }
    
} catch {
    Write-ColoredOutput "Error during production deployment: $($_.Exception.Message)" "Red"
    Write-ColoredOutput "Stack trace: $($_.ScriptStackTrace)" "Red"
    exit 1
}