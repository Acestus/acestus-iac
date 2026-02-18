# Deploy Aspire Dashboard for Development Environment
# This script deploys the .NET Aspire Dashboard infrastructure to the development environment

param(
    [string]$SubscriptionId = $env:AZURE_SUBSCRIPTION_ID,
    [string]$ResourceGroupName = "rg-aspire-dev-eus2-001",
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
    Write-ColoredOutput "Starting Aspire Dashboard deployment for Development environment..." "Green"
    
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
    $deploymentName = "aspire-dashboard-dev-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
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
    
    # Confirm deployment unless Force is specified
    if (-not $Force) {
        $confirmation = Read-Host "Proceed with deployment? (y/N)"
        if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
            Write-ColoredOutput "Deployment cancelled by user." "Yellow"
            return
        }
    }
    
    Write-ColoredOutput "Starting deployment..." "Green"
    
    # Deploy the template
    $deployment = New-AzResourceGroupDeployment `
        -Name $deploymentName `
        -ResourceGroupName $ResourceGroupName `
        -TemplateParameterFile $parametersFile `
        -Verbose
    
    if ($deployment.ProvisioningState -eq "Succeeded") {
        Write-ColoredOutput "Deployment completed successfully!" "Green"
        
        # Display outputs
        Write-ColoredOutput "`nDeployment Outputs:" "Yellow"
        foreach ($output in $deployment.Outputs.GetEnumerator()) {
            Write-ColoredOutput "  $($output.Key): $($output.Value.Value)" "White"
        }
        
        # Display Aspire Dashboard URL
        if ($deployment.Outputs.aspireDashboardUrl) {
            Write-ColoredOutput "`n🎉 Aspire Dashboard is available at:" "Green"
            Write-ColoredOutput "   $($deployment.Outputs.aspireDashboardUrl.Value)" "Cyan"
        }
        
        # Display OTLP endpoint
        if ($deployment.Outputs.otlpEndpointUrl) {
            Write-ColoredOutput "`n📡 OTLP Endpoint for telemetry:" "Green"
            Write-ColoredOutput "   $($deployment.Outputs.otlpEndpointUrl.Value)" "Cyan"
        }
        
    } else {
        Write-ColoredOutput "Deployment failed with state: $($deployment.ProvisioningState)" "Red"
        exit 1
    }
    
} catch {
    Write-ColoredOutput "Error during deployment: $($_.Exception.Message)" "Red"
    Write-ColoredOutput "Stack trace: $($_.ScriptStackTrace)" "Red"
    exit 1
}