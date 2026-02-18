# Configure Application Insights and Scaling for Function App
# This script deploys only the configuration updates for Application Insights and scaling

param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-acemgt-dev-usw2-001"
)

# Set error handling
$ErrorActionPreference = "Stop"

Write-Host "🔧 Configuring Application Insights and scaling settings..." -ForegroundColor Green

try {
    # Ensure user is logged into Azure
    Write-Host "🔐 Checking Azure authentication..." -ForegroundColor Yellow
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Please log into Azure first using 'Connect-AzAccount'" -ForegroundColor Red
        exit 1
    }
    
    # Deploy the Bicep template to update configuration
    Write-Host "⚙️ Updating function app configuration..." -ForegroundColor Yellow
    $deploymentName = "config-update-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    $deploymentResult = New-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile ".\main.bicep" `
        -TemplateParameterFile ".\main.bicepparam" `
        -Name $deploymentName `
        -Verbose
    
    if ($deploymentResult.ProvisioningState -eq "Succeeded") {
        Write-Host "✅ Configuration update completed successfully!" -ForegroundColor Green
        
        # Display configuration summary
        Write-Host "`n🎉 Configuration Summary:" -ForegroundColor Green
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host "✅ Application Insights: Enabled and configured" -ForegroundColor White
        Write-Host "✅ Dynamic Scaling: Configured for Consumption plan" -ForegroundColor White
        Write-Host "✅ PowerShell Runtime: Set to 7.4" -ForegroundColor White
        Write-Host "✅ Storage Configuration: Updated for scaling" -ForegroundColor White
        Write-Host "✅ Teams Action Group: Updated" -ForegroundColor White
        
        Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Check Azure Portal - Application Insights should now show as 'On'" -ForegroundColor White
        Write-Host "2. Monitor function executions in Application Insights" -ForegroundColor White
        Write-Host "3. Test alert processing to verify scaling works properly" -ForegroundColor White
        
    } else {
        Write-Host "❌ Configuration update failed: $($deploymentResult.ProvisioningState)" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ Configuration update failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}

Write-Host "`n🎯 Application Insights and scaling configuration completed!" -ForegroundColor Green