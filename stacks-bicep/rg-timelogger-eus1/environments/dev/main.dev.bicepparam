using '../../main.bicep'

param projectName = 'timelogger'
param environment = 'dev'
param regionCode = 'eus1'
param instanceNumber = '001'
param location = 'eastus'

param tags = {
  ManagedBy: 'https://github.com/acestus/acestus-iac'
  CreatedBy: 'acestus'
  Environment: environment == 'prd' ? 'Production' : environment == 'stg' ? 'Staging' : 'Development'
  Project: 'Time Logger - AKS .NET Microservice'
  CAFName: '${projectName}-${environment}-${regionCode}-${instanceNumber}'
  CostCenter: 'Development'
  Subscription: 'Acestus
}

// AKS Configuration - Cost optimized for dev
param kubernetesVersion = '1.30'
param aksSkuTier = 'Free'
param systemPoolSize = 'CostOptimised'
param agentPoolSize = '' // No additional agent pool for dev

// AKS Security - Relaxed for dev
param enableAzureRbac = true
param disableLocalAccounts = false
param enableKeyvaultSecretsProvider = false

// ACR Configuration
param acrSku = 'Basic'

// Storage Configuration
param storageSkuName = 'Standard_LRS'
param enableBlobSoftDelete = false // Not needed for dev

// Networking
param networkPlugin = 'azure'
param networkPolicy = 'azure'

// Principal for role assignments - your Service Principal or User Object ID
param principalId = '00000000-0000-0000-0000-000000000000' // Replace with actual principal ID
param principalType = 'ServicePrincipal'
