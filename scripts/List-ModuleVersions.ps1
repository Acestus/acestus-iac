# List Module Versions in Azure Container Registry
# This script lists all published versions of modules in ACR

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ModuleName,
    
    [Parameter(Mandatory = $false)]
    [string]$RegistryName = "acrskpmgtcrdevukw001",
    
    [Parameter(Mandatory = $false)]
    [string]$ModulePrefix = "bicep/modules"
)

$ErrorActionPreference = "Stop"

Write-Host "Listing Module Versions in ACR" -ForegroundColor Green
Write-Host "Registry: $RegistryName" -ForegroundColor Yellow

try {
    # Test Azure CLI connectivity
    Write-Host "\nChecking Azure CLI authentication..." -ForegroundColor Cyan
    $currentUser = az account show --query "user.name" -o tsv 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Azure CLI not authenticated. Please run 'az login'"
    }

    # Check ACR access (using repository list which requires less privileges than acr show)
    Write-Host "Checking ACR access..." -ForegroundColor Cyan
    $acrCheck = az acr repository list --name $RegistryName --output tsv 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Cannot access ACR '$RegistryName'. Check permissions and registry name."
    }
    
    if ($ModuleName) {
        # List versions for specific module
        Write-Host "Module: $ModuleName" -ForegroundColor Blue
        Write-Host "="*60 -ForegroundColor Blue
        
        $repository = "$ModulePrefix/$ModuleName"
        $tags = az acr repository show-tags --name $RegistryName --repository $repository --output json 2>$null | ConvertFrom-Json
        
        if ($LASTEXITCODE -ne 0 -or -not $tags) {
            Write-Host "Module '$ModuleName' not found in registry" -ForegroundColor Red
            return
        }
        
        # Get detailed information for each tag
        $moduleVersions = @()
        foreach ($tag in $tags) {
            try {
                $manifest = az acr repository show-manifests --name $RegistryName --repository $repository --tag $tag --output json 2>$null | ConvertFrom-Json
                if ($manifest -and $manifest.Count -gt 0) {
                    $moduleVersions += [PSCustomObject]@{
                        Version = $tag
                        CreatedTime = $manifest[0].timestamp
                        Digest = $manifest[0].digest.Substring(0, 12) + "..."
                        Size = if ($manifest[0].configMediaType) { 
                            [math]::Round($manifest[0].imageSize / 1024, 2) 
                        } else { 
                            "N/A" 
                        }
                    }
                }
            } catch {
                $moduleVersions += [PSCustomObject]@{
                    Version = $tag
                    CreatedTime = "Unknown"
                    Digest = "Unknown"
                    Size = "Unknown"
                }
            }
        }
        
        if ($moduleVersions.Count -gt 0) {
            $moduleVersions | Sort-Object CreatedTime -Descending | Format-Table -Property Version, CreatedTime, Digest, Size -AutoSize
            Write-Host "Total versions: $($moduleVersions.Count)" -ForegroundColor Green
            Write-Host "Latest version: $($moduleVersions[0].Version)" -ForegroundColor Green
        }
        
    } else {
        # List all modules and their versions
        Write-Host "All Modules in Registry" -ForegroundColor Blue
        Write-Host "="*60 -ForegroundColor Blue
        
        $repositories = az acr repository list --name $RegistryName --output json 2>$null | ConvertFrom-Json
        
        if ($LASTEXITCODE -ne 0 -or -not $repositories) {
            Write-Host "No repositories found or failed to access registry" -ForegroundColor Red
            return
        }
        
        # Filter for Bicep modules
        $bicepModules = $repositories | Where-Object { $_ -like "$ModulePrefix/*" }
        
        if (-not $bicepModules) {
            Write-Host "No Bicep modules found in registry under prefix '$ModulePrefix'" -ForegroundColor Red
            return
        }
        
        $allModules = @()
        foreach ($repo in $bicepModules) {
            try {
                $moduleName = $repo.Replace("$ModulePrefix/", "")
                $tags = az acr repository show-tags --name $RegistryName --repository $repo --output json 2>$null | ConvertFrom-Json
                
                if ($tags -and $tags.Count -gt 0) {
                    # Get the latest tag info
                    $latestManifest = az acr repository show-manifests --name $RegistryName --repository $repo --top 1 --output json 2>$null | ConvertFrom-Json
                    
                    $allModules += [PSCustomObject]@{
                        Module = $moduleName
                        Repository = $repo
                        Versions = $tags.Count
                        LatestVersion = $tags | Sort-Object -Descending | Select-Object -First 1
                        LastUpdated = if ($latestManifest -and $latestManifest.Count -gt 0) { 
                            $latestManifest[0].timestamp 
                        } else { 
                            "Unknown" 
                        }
                    }
                }
            } catch {
                $allModules += [PSCustomObject]@{
                    Module = $repo.Replace("$ModulePrefix/", "")
                    Repository = $repo
                    Versions = "Error"
                    LatestVersion = "Unknown"
                    LastUpdated = "Unknown"
                }
            }
        }
        
        if ($allModules.Count -gt 0) {
            $allModules | Sort-Object Module | Format-Table -Property Module, Versions, LatestVersion, LastUpdated -AutoSize
            Write-Host "Total modules: $($allModules.Count)" -ForegroundColor Green
        } else {
            Write-Host "No modules found" -ForegroundColor Red
        }
    }
    
    # Show usage example
    Write-Host "\nUsage Examples:" -ForegroundColor Yellow
    if ($ModuleName) {
        Write-Host "module myStorage 'br:$RegistryName.azurecr.io/$ModulePrefix/$ModuleName`:$($moduleVersions[0].Version)' = {" -ForegroundColor White
        Write-Host "  // module parameters" -ForegroundColor Green
        Write-Host "}" -ForegroundColor White
    } else {
        if ($allModules.Count -gt 0) {
            $exampleModule = $allModules[0]
            Write-Host "module example 'br:$RegistryName.azurecr.io/$ModulePrefix/$($exampleModule.Module)`:$($exampleModule.LatestVersion)' = {" -ForegroundColor White
            Write-Host "  // module parameters" -ForegroundColor Green
            Write-Host "}" -ForegroundColor White
        }
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}