# Push containers to Azure Container Registry (local Docker build)
# Usage: .\scripts\push-containers.ps1 [-Tag <tag>] [-Apps <app1,app2>]

param(
    [string]$Tag = "latest",
    [string[]]$Apps = @("api-traffic", "fabric-sync"),
    [string]$AcrName = "<your-acr-name>",  # e.g., acrtimeloggerdevusw2001
    [string]$SubscriptionId = "<your-subscription-id>"
)

$ErrorActionPreference = "Stop"
$AcrLoginServer = "$AcrName.azurecr.io"

Write-Host "Setting Azure subscription..." -ForegroundColor Cyan
az account set --subscription $SubscriptionId

Write-Host "Logging into ACR: $AcrName" -ForegroundColor Cyan
az acr login --name $AcrName

foreach ($app in $Apps) {
    $contextPath = Join-Path $PSScriptRoot "..\$app"

    if (-not (Test-Path $contextPath)) {
        Write-Host "Directory not found: $contextPath" -ForegroundColor Red
        continue
    }

    $imageName = "$AcrLoginServer/${app}:$Tag"

    Write-Host "`nBuilding $app..." -ForegroundColor Yellow
    docker build -t $imageName $contextPath

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to build $app" -ForegroundColor Red
        exit 1
    }

    Write-Host "Pushing $imageName..." -ForegroundColor Yellow
    docker push $imageName

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to push $app" -ForegroundColor Red
        exit 1
    }

    Write-Host "Pushed: $imageName" -ForegroundColor Green
}

Write-Host "`nAll images pushed successfully!" -ForegroundColor Green
