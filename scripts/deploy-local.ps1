#!/usr/bin/env pwsh
# Deploy applications to local Kubernetes cluster

param(
    [switch]$Build = $true
)

$ErrorActionPreference = "Stop"

Write-Host "🔨 Local Kubernetes Deployment" -ForegroundColor Cyan

# Check if kubectl is available
if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Error "kubectl not found. Make sure Kubernetes is enabled in Docker Desktop."
    exit 1
}

# Check if cluster is running
try {
    kubectl cluster-info | Out-Null
}
catch {
    Write-Error "Kubernetes cluster not running. Enable it in Docker Desktop."
    exit 1
}

if ($Build) {
    Write-Host "`n📦 Building Docker images..." -ForegroundColor Yellow

    Write-Host "  Building api-traffic..." -ForegroundColor Gray
    docker build -t api-traffic:local ./api-traffic

    Write-Host "✅ Images built successfully" -ForegroundColor Green
}

Write-Host "`n🚀 Deploying to Kubernetes..." -ForegroundColor Yellow

# Deploy api-traffic
Write-Host "  Deploying api-traffic..." -ForegroundColor Gray
kubectl apply -f k8s/api-traffic/deployment.local.yaml
kubectl apply -f k8s/api-traffic/service.local.yaml

Write-Host "✅ Deployed successfully" -ForegroundColor Green

Write-Host "`n⏳ Waiting for pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=api-traffic --timeout=60s

Write-Host "`n✅ All pods are ready!" -ForegroundColor Green

Write-Host "`n📊 Status:" -ForegroundColor Cyan
kubectl get pods, svc

Write-Host "`n🌐 Access your applications:" -ForegroundColor Cyan
Write-Host "  api-traffic: http://localhost:30080" -ForegroundColor White

Write-Host "`n💡 Useful commands:" -ForegroundColor Cyan
Write-Host "  kubectl logs -l app=api-traffic --tail=50 -f" -ForegroundColor Gray
Write-Host "  kubectl get pods" -ForegroundColor Gray
Write-Host "  kubectl describe pod <pod-name>" -ForegroundColor Gray
