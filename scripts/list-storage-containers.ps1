#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Lists containers in the api storage account.

.DESCRIPTION
    Lists all blob containers in the storage account using Azure CLI.
    Requires Azure CLI to be installed and logged in.

.PARAMETER StorageAccount
    The storage account name. Defaults to stapidevusw2001.

.PARAMETER ResourceGroup
    The resource group name. Defaults to rg-api-dev-usw2-001.

.EXAMPLE
    .\list-storage-containers.ps1

.EXAMPLE
    .\list-storage-containers.ps1 -StorageAccount mystorageaccount -ResourceGroup myresourcegroup
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

# List containers
Write-Host "Containers in $StorageAccount`:" -ForegroundColor Green
az storage container list `
    --account-name $StorageAccount `
    --auth-mode login `
    --query "[].{Name:name, LastModified:properties.lastModified, PublicAccess:properties.publicAccess}" `
    --output table
