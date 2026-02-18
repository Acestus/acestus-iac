# Deploy Alert Transformer Function to Azure - Identity
# This script deploys the alert transformer infrastructure and function code

param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId = "c06072ff-5e1d-48ae-9d1a-cea0834bc1aa",
    
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-acestus-idnt-usw2-001",
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "West US 2"
)

# Set error handling
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Alert Transformer deployment..." -ForegroundColor Green

try {
    # Ensure user is logged into Azure
    Write-Host "🔐 Checking Azure authentication..." -ForegroundColor Yellow
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Please log into Azure first using 'Connect-AzAccount'" -ForegroundColor Red
        exit 1
    }
    
    # Set the subscription
    Write-Host "🎯 Setting subscription to $SubscriptionId..." -ForegroundColor Yellow
    Set-AzContext -SubscriptionId $SubscriptionId
    
    # Ensure resource group exists
    Write-Host "📦 Checking/creating resource group '$ResourceGroupName'..." -ForegroundColor Yellow
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-Host "Creating resource group '$ResourceGroupName'..." -ForegroundColor Yellow
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    } else {
        Write-Host "Resource group '$ResourceGroupName' already exists" -ForegroundColor Green
    }
    
    # Get existing function app
    Write-Host "📱 Getting existing function app..." -ForegroundColor Yellow
    $functionAppName = "func-alert-idnt-usw2-001"
    $functionApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $functionAppName
    if (-not $functionApp) {
        Write-Host "❌ Function app '$functionAppName' not found" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Found function app: $($functionApp.Name)" -ForegroundColor Green
    
    # Create and deploy function code package
    Write-Host "📦 Creating function deployment package..." -ForegroundColor Yellow
        
        # Create temporary directory for packaging
        $tempDir = Join-Path $env:TEMP "alert-transformer-$(Get-Date -Format 'yyyyMMddHHmmss')"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        try {
            # Copy function files to temp directory
            Copy-Item -Path ".\Alert_Transformer" -Destination $tempDir -Recurse -Force
            Copy-Item -Path ".\host.json" -Destination $tempDir -Force
            Copy-Item -Path ".\requirements.psd1" -Destination $tempDir -Force
            
            # Create ZIP file for deployment
            $zipPath = Join-Path $env:TEMP "alert-transformer-deployment.zip"
            if (Test-Path $zipPath) {
                Remove-Item $zipPath -Force
            }
            
            # Create zip file
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath)
            
            Write-Host "📤 Deploying function code to Azure..." -ForegroundColor Yellow
            
            # Deploy the ZIP package to the function app using REST API
            $functionApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $functionAppName
            $publishProfile = Get-AzWebAppPublishingProfile -ResourceGroupName $ResourceGroupName -Name $functionAppName -OutputFile $null -Format WebDeploy
            
            # Extract credentials from publish profile
            [xml]$profile = $publishProfile
            $creds = $profile.publishData.publishProfile | Where-Object { $_.publishMethod -eq "MSDeploy" }
            $username = $creds.userName
            $password = $creds.userPWD
            $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$username`:$password"))
            
            # Deploy using Kudu REST API
            $kuduUrl = "https://$functionAppName.scm.azurewebsites.net/api/zipdeploy"
            $headers = @{
                "Authorization" = "Basic $base64Auth"
                "Content-Type" = "application/zip"
            }
            
            $response = Invoke-RestMethod -Uri $kuduUrl -Method POST -InFile $zipPath -Headers $headers -TimeoutSec 300
            
            Write-Host "✅ Function code deployed successfully!" -ForegroundColor Green
            Write-Host "🌐 Function URL: https://$($functionApp.DefaultHostName)/api/Alert_Transformer" -ForegroundColor Cyan
            
        } finally {
            # Clean up temporary files
            if (Test-Path $tempDir) {
                Remove-Item $tempDir -Recurse -Force
            }
            if (Test-Path $zipPath) {
                Remove-Item $zipPath -Force
            }
        }
        
        # Display deployment summary
        Write-Host "`n🎉 Deployment Summary:" -ForegroundColor Green
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host "Function App: $functionAppName" -ForegroundColor White
        Write-Host "Function URL: https://$($functionApp.DefaultHostName)/api/Alert_Transformer" -ForegroundColor White
        Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor White
        
        Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Test the function by sending a POST request to the function URL" -ForegroundColor White
        Write-Host "2. Configure Azure Monitor alerts to use the Teams Action Group" -ForegroundColor White
        Write-Host "3. Verify that alerts are properly transformed and sent to Teams" -ForegroundColor White
        
} catch {
    Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}

Write-Host "`n🎯 Alert Transformer function deployment completed successfully!" -ForegroundColor Green