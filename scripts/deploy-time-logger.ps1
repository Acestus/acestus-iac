# Deploy Time Logger to AKS
# This script gets the storage connection string and creates the Kubernetes secret

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('dev', 'stg', 'prd')]
    [string]$Environment = 'dev'
)

$ErrorActionPreference = 'Stop'

# Resource names
$resourceGroup = "rg-timelogger-$Environment-ukw-001"
$storageAccount = "sttimelogger$($Environment)ukw001"
$aksCluster = "aks-timelogger-$Environment-ukw-001"

Write-Host "Getting storage connection string..." -ForegroundColor Cyan
$connectionString = az storage account show-connection-string `
    --name $storageAccount `
    --resource-group $resourceGroup `
    --query connectionString `
    --output tsv

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to get storage connection string"
    exit 1
}

Write-Host "Creating Kubernetes secret..." -ForegroundColor Cyan
kubectl create secret generic storage-secret `
    --from-literal=connection-string="$connectionString" `
    --dry-run=client -o yaml | kubectl apply -f -

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create secret"
    exit 1
}

Write-Host "Building and pushing time-logger image..." -ForegroundColor Cyan
$acrName = "<your-acr-name>"  # e.g., acrtimeloggerdevukw001
docker build -t "$acrName.azurecr.io/time-logger:latest" ./time-logger

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build image"
    exit 1
}

az acr login --name $acrName
docker push "$acrName.azurecr.io/time-logger:latest"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to push image"
    exit 1
}

Write-Host "Deploying CronJob to AKS..." -ForegroundColor Cyan
kubectl apply -f k8s/time-logger/cronjob.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to deploy CronJob"
    exit 1
}

Write-Host "`nDeployment complete!" -ForegroundColor Green
Write-Host "`nVerify deployment:" -ForegroundColor Yellow
Write-Host "  kubectl get cronjob time-logger"
Write-Host "  kubectl get jobs"
Write-Host "`nView logs:" -ForegroundColor Yellow
Write-Host "  kubectl get pods -l job-name=<job-name>"
Write-Host "  kubectl logs <pod-name>"
Write-Host "`nCheck storage:" -ForegroundColor Yellow
Write-Host "  az storage blob list --account-name $storageAccount --container-name time-logs --output table"
