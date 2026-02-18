using '../../main.bicep'

param projectName = 'timelogger'
param environment = 'dev'
param regionCode = 'eus1'
param instanceNumber = '001'
param location = 'eastus'
param createdBy = 'wweeks'

param tags = {
  Project: 'TimeLogger AKS Application'
  ManagedBy: 'https://github.com/your-org/acestus-iac'
  CostCenter: 'Development'
}

// AKS Configuration - Cost optimized for dev
param kubernetesVersion = '1.30'
param aksSkuTier = 'Free'
param systemPoolSize = 'CostOptimised'
param agentPoolSize = ''  // No additional agent pool for dev

// AKS Security - Relaxed for dev
param enableAzureRbac = true
param disableLocalAccounts = false
param enableKeyvaultSecretsProvider = false

// ACR Configuration
param acrSku = 'Basic'

// Storage Configuration  
param storageSkuName = 'Standard_LRS'
param enableBlobSoftDelete = false  // Not needed for dev

// Networking
param networkPlugin = 'azure'
param networkPolicy = 'azure'

// Principal for role assignments - your Service Principal or User Object ID
param principalId = '00000000-0000-0000-0000-000000000000'  // Replace with actual principal ID
param principalType = 'ServicePrincipal'
