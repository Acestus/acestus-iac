# Bicep Infrastructure

## Scripts

### Deploy a Bicep Stack

```powershell
# Deploy to dev environment
.\scripts\deploy-bicep.ps1 -Stack rg-aceedm-eus2 -Environment dev

# Deploy to prd environment
.\scripts\deploy-bicep.ps1 -Stack rg-aceedm-eus2 -Environment prd
```

### Create a Resource Group

```powershell
# Basic usage (defaults to westus2)
.\scripts\New-ResourceGroup.ps1 -Name "rg-myproject-dev-eus2-001"

# With location and subscription
.\scripts\New-ResourceGroup.ps1 -Name "rg-myproject-dev-eus2-001" -Location "eastus" -Subscription "Acestus"
```

## Style Guide

* One directory per resource group
* One workflow yaml per resource group
* Deploy with `az deployment group create` only. No `az deployment sub create` or `az deployment tenant create` because it breaks --what-if.
* Use [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/indexes/bicep/bicep-resource-modules/) only.
* Do not reference values in other directories. Duplicate the values if needed. The directory is self-contained with no dependencies. This violates DRY, but it is easier for SysOps to maintain.
* 1. You are now code reviewers. It has its own culture to prevent offending people. Here are some [conventional comments](https://conventionalcomments.org/). I.E. "issue (non-blocking): This is not worded correctly."


## IAC Lab

[Lab Video](<internal-training-video-url>)

1. Open the Web Editor by pressing '.'
1. Create a Branch with [Cloud Adoption Frameworking naming convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) like "lab-sbox-eus2"
1. Copy .github/workflows/$ProjectName-$Environment-$CAFLocation.yaml and rename it with Ctrl-Shift-L
1. Copy the folder, $ProjectName-$Environment-$CAFLocation, and rename it.
1. Update the values in the yaml file.
1. Update the values in the bicepparam file.
1. Press Ctrl-Shift-G, type in a message, then Commit & Push
1. Confirm the Storage account was create in GitHub Actions and the Azure Portal.

## Deploy IAC to Prod

[Deployment Video](<internal-training-video-url>)

1. Create a new branch following the Cloud Adoption Framework naming convention. For example, "mgmt710-corp-eus2".
1. Copy and customize these files:
    - directory, mgmt710-corp-eus2
        - 1 bicep file, mgmt710-corp-eus2.bicep
        - 2 bicep parameter files, mgmt710-corp-eus2-prd.parameters.json and mgmt710-corp-eus2-dev.parameters.json
        - 2 powershell files, tests-prd.ps1 and tests-dev.ps1
    - workflow yaml file, mgmt710-corp-eus2-prd.yaml
    - workflow yaml file, mgmt710-corp-eus2-dev.yaml
1. Deploy to your sandbox subscription in your branch.
1. Run ./tests-dev.ps1 to validate the deployment.
1. Create a pull request to the main branch. The workflow will run and deploy to the production subscription.
1. Run ./tests-prd.ps1 to validate the deployment.
1. Delete the dev resources, modify 'Action: create' to 'Action: delete' in the workflow yaml file and run the workflow.
1. Once your work is rebased to main, delete your branch in GitHub to keep branches tiny:
    - Remotely: git push origin --delete $branchname
    - Locally: git switch main; git pull; git branch --delete $branchname
