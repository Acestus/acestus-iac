# Bicep Infrastructure

## Azure Subscriptions

| Subscription Name | Subscription ID | Management Group | Status |
|-------------------|-----------------|------------------|--------|
| Corp-710-Analytics | 3f9e26da-8dad-4891-99f4-be054a040743 | Acestus-corp | Active |
| Corp-750-HumanResources | 6716a076-b1d1-4e29-8922-dcc79856624d | Acestus-corp | Active |
| Sbox-510-Infrastructure | 9263a29c-4805-4ee3-b5df-9f36319f333e | Acestus-sandboxes | Active |
| Management | e35cd2cf-a9de-4d2b-9134-8b341286cb5d | Acestus-management | Active |
| Connectivity | 7c486f82-99db-43fe-9858-78ae54a74f3b | Acestus-connectivity | Active |
| Sbox-LearningLab | 8a0d1fba-54d6-4f26-86a9-04aa58ba7fb0 | Acestus-sandboxes | Active |
| Sbox-750-HumanResources | c65a4566-c17e-454f-ad2c-4fa63dcc9447 | Acestus-sandboxes | Active |
| Sbox-530-EnterpriseDataManagement | f9be9789-e60d-4594-8462-2cfd5e964e77 | Acestus-sandboxes | Active |
| Onln-520-ApplicationDevelopment | b77da62c-463a-4fd2-a1cc-9a9a42736a48 | Acestus-online | Active |
| Corp-100-Marketing | e0f9cbe0-b164-401a-8732-806aadbc0b4c | Acestus-corp | Active |
| Sbox-710-Analytics | 3377da5d-603f-4c5a-ad22-e7b2ee498edf | Acestus-sandboxes | Active |
| Sbox-520-ApplicationDevelopment | cd1c019c-0e19-41b8-a86a-8c1c36fbcd38 | Acestus-sandboxes | Active |
| Onln-100-Marketing | f87322ed-0ccb-4a1a-a306-134f3fc0df3e | Acestus-online | Active |
| Corp-520-ApplicationDevelopment | f19297b6-1543-4ad2-9f2e-4ba8da5c406b | Acestus-corp | Active |
| Sandbox 1 | ea59ddc0-e1cc-4f79-b45d-93b38ef7b362 | Acestus-sandboxes | Active |
| Onln-530-EnterpriseDataManagement | 413b4a79-a957-4a0a-893e-19bbbfa2dbe7 | Acestus-online | Active |
| Corp-530-EnterpriseDataManagement | 8b67b073-f765-482f-82ad-ede639aef462 | Acestus-corp | Active |
| Identity | c06072ff-5e1d-48ae-9d1a-cea0834bc1aa | Acestus-identity | Active |
| Sbox-100-Marketing | 15bd7f92-277b-4f7e-b3f8-96cdb38cb03f | Acestus-sandboxes | Active |

## Scripts

### Deploy a Bicep Stack

```powershell
# Deploy to dev environment
.\scripts\deploy-bicep.ps1 -Stack rg-aceedm-usw2 -Environment dev

# Deploy to prd environment
.\scripts\deploy-bicep.ps1 -Stack rg-aceedm-usw2 -Environment prd
```

### Create a Resource Group

```powershell
# Basic usage (defaults to westus2)
.\scripts\New-ResourceGroup.ps1 -Name "rg-myproject-dev-usw2-001"

# With location and subscription
.\scripts\New-ResourceGroup.ps1 -Name "rg-myproject-dev-usw2-001" -Location "eastus" -Subscription "Sbox-710-Analytics"
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
1. Create a Branch with [Cloud Adoption Frameworking naming convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) like "lab-sbox-usw2"
1. Copy .github/workflows/$ProjectName-$Environment-$CAFLocation.yaml and rename it with Ctrl-Shift-L
1. Copy the folder, $ProjectName-$Environment-$CAFLocation, and rename it.
1. Update the values in the yaml file.
1. Update the values in the bicepparam file.
1. Press Ctrl-Shift-G, type in a message, then Commit & Push
1. Confirm the Storage account was create in GitHub Actions and the Azure Portal.

## Deploy IAC to Prod

[Deployment Video](<internal-training-video-url>)

1. Create a new branch following the Cloud Adoption Framework naming convention. For example, "mgmt710-corp-usw2".
1. Copy and customize these files:
    - directory, mgmt710-corp-usw2
        - 1 bicep file, mgmt710-corp-usw2.bicep
        - 2 bicep parameter files, mgmt710-corp-usw2-prd.parameters.json and mgmt710-corp-usw2-dev.parameters.json
        - 2 powershell files, tests-prd.ps1 and tests-dev.ps1
    - workflow yaml file, mgmt710-corp-usw2-prd.yaml
    - workflow yaml file, mgmt710-corp-usw2-dev.yaml
1. Deploy to your sandbox subscription in your branch.
1. Run ./tests-dev.ps1 to validate the deployment.
1. Create a pull request to the main branch. The workflow will run and deploy to the production subscription.
1. Run ./tests-prd.ps1 to validate the deployment.
1. Delete the dev resources, modify 'Action: create' to 'Action: delete' in the workflow yaml file and run the workflow.
1. Once your work is rebased to main, delete your branch in GitHub to keep branches tiny:
    - Remotely: git push origin --delete $branchname
    - Locally: git switch main; git pull; git branch --delete $branchname
     