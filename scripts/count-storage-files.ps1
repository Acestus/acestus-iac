#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Counts files (blobs) in each container of the api storage account.

.DESCRIPTION
    Lists all blob containers and counts the number of blobs in each.
    Requires Azure CLI to be installed and logged in.

.PARAMETER StorageAccount
    The storage account name. Defaults to stapidevusw2001.

.PARAMETER ResourceGroup
    The resource group name. Defaults to rg-api-dev-usw2-001.

.EXAMPLE
    .\count-storage-files.ps1

.EXAMPLE
    .\count-storage-files.ps1 -StorageAccount mystorageaccount
#>

param(
    [string]$StorageAccount = "stapidevusw2001",
    [string]$ResourceGroup = "rg-api-dev-usw2-001"
)

$ErrorActionPreference = "Stop"

# Check if logged in to Azure
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Error "Not logged in to Azure. Run 'az login' first."
    exit 1
}

Write-Host "Using subscription: $($account.name)" -ForegroundColor Cyan
Write-Host "Storage account: $StorageAccount" -ForegroundColor Cyan
Write-Host ""

# Get all containers
$containersJson = & cmd /c "az storage container list --account-name $StorageAccount --auth-mode login --query `"[].name`" -o json"
$containers = $containersJson | ConvertFrom-Json

if (-not $containers -or $containers.Count -eq 0) {
    Write-Host "No containers found in storage account." -ForegroundColor Yellow
    exit 0
}

Write-Host "Container File Counts:" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green

$totalFiles = 0

foreach ($container in $containers) {
    # Count blobs in container
    $countResult = & cmd /c "az storage blob list --account-name $StorageAccount --container-name $container --auth-mode login --query `"length(@)`" -o tsv"
    $count = [int]$countResult
    $totalFiles += $count

    Write-Host ("{0,-30} {1,8} files" -f $container, $count)
}

Write-Host "======================" -ForegroundColor Green
Write-Host ("{0,-30} {1,8} files" -f "TOTAL", $totalFiles) -ForegroundColor Cyan
