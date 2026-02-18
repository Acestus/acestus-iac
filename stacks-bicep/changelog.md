# Infrastructure Updates Summary

## Overview
Updated both Identity and Enterprise Data Management (EDM) resource groups to deploy to their respective subscriptions:

### Identity Subscription
- **Subscription**: `c06072ff-5e1d-48ae-9d1a-cea0834bc1aa` (Identity)
- **Resource Group**: `rg-identity-usw2-001`
- **Resources**: App Service Plan, Application Insights, Storage Account, Function App, Action Groups
- **Naming Convention**: Resources prefixed with "idnt"

### Enterprise Data Management Subscription  
- **Subscription**: `8b67b073-f765-482f-82ad-ede639aef462` (Corp-530-EnterpriseDataManagement)
- **Resource Group**: `rg-edm-usw2-001`
- **Resources**: App Service Plan, Application Insights, Storage Account, Function App, Action Groups  
- **Naming Convention**: Resources prefixed with "edm"

## Changes Made

### Template Architecture
- Changed `targetScope` from `'resourceGroup'` to `'subscription'`
- Added resource group creation within the template
- Updated all modules to use `scope: rg` to deploy into the created resource group
- Created separate `actionGroup.bicep` modules for proper scoping

### Resource Naming
**Identity Resources:**
- App Service Plan: `asp-idnt-prd-usw2-001`
- Application Insights: `ai-idnt-prd-usw2-001`
- Storage Account: `stidntprdusw2001`
- Function App: `func-idnt-alert-prd-usw2-001`
- Action Groups: `ag-idnt-email-usw2-001`, `ag-idnt-teams-usw2-001`

**EDM Resources:**
- App Service Plan: `asp-edm-prd-usw2-001`
- Application Insights: `ai-edm-prd-usw2-001`  
- Storage Account: `stedmprdusw2001`
- Function App: `func-edm-alert-prd-usw2-001`
- Action Groups: `ag-edm-email-usw2-001`, `ag-edm-teams-usw2-001`

### Deployment Scripts
- Updated to use `az stack sub create` for subscription-level deployments
- Modified stack names: `stack-identity-usw2-001` and `stack-edm-usw2-001`
- Added subscription context switching to target correct subscriptions

### Configuration Updates
- Updated Log Analytics workspace references to use subscription-specific paths
- Updated cost center and department tags to reflect correct billing
- Set environment suffix to `prd` (production) for both deployments

## Deployment Instructions

### Prerequisites
1. Ensure you have appropriate permissions in both target subscriptions
2. Verify Azure CLI is installed and authenticated
3. Confirm Log Analytics workspaces exist in the target subscriptions

### Deploy Identity Resources
```powershell
cd "<your-repo-path>\bicep-infra\rg-acestus-idnt-usw2-001"
.\deploy-bicep-stack.ps1 -StackName "stack-identity-usw2-001" -SubscriptionId "c06072ff-5e1d-48ae-9d1a-cea0834bc1aa"
```

### Deploy EDM Resources  
```powershell
cd "<your-repo-path>\bicep-infra\rg-acestus-edm-usw2-001"
.\deploy-bicep-stack.ps1 -StackName "stack-edm-usw2-001" -SubscriptionId "8b67b073-f765-482f-82ad-ede639aef462"
```

## Next Steps

1. **Validate Permissions**: Ensure deployment account has Contributor access to both subscriptions
2. **Create Log Analytics Workspaces**: Verify these exist or update the workspace resource IDs in the parameter files:
   - Identity: `/subscriptions/<subscription-id>/resourceGroups/rg-identity-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-identity-usw2`
   - EDM: `/subscriptions/<subscription-id>/resourceGroups/rg-edm-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-edm-usw2`
3. **Test Deployments**: Run the deployment scripts in validation mode first
4. **Configure Function Apps**: Deploy the Alert_Transformer PowerShell code after infrastructure deployment
5. **Validate Billing**: Confirm resources are being billed to the correct subscriptions

## Files Modified

### Identity (rg-acestus-idnt-usw2-001)
- `main.bicep` - Updated for subscription scope and naming
- `main.bicepparam` - Updated subscription and resource group targets
- `deploy-bicep-stack.ps1` - Updated for subscription deployment
- `actionGroup.bicep` - New module for Action Groups (created)

### EDM (rg-acestus-edm-usw2-001)  
- `main.bicep` - Updated for subscription scope and naming
- `main.bicepparam` - Updated subscription and resource group targets
- `deploy-bicep-stack.ps1` - Updated for subscription deployment
- `actionGroup.bicep` - New module for Action Groups (created)