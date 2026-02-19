using '../../main.bicep'

param projectName = 'acestus'
param environment = 'stg'
param regionCode = 'scus'
param instanceNumber = '001'
param location = 'southcentralus'

param tags = {
  CreatedBy: 'acestus'
  Project: 'Time Logger - AKS .NET Microservice'
  ManagedBy: 'https://github.com/your-org/acestus-iac'
  CostCenter: 'Staging'
  Subscription: 'Acestus'
}

// AKS Configuration - Balanced for staging
param kubernetesVersion = '1.30'
param aksSkuTier = 'Standard'
param systemPoolSize = 'Standard'
param agentPoolSize = '' // No additional agent pool for staging

// AKS Security
param enableAzureRbac = true
param disableLocalAccounts = true
param enableKeyvaultSecretsProvider = true

// ACR Configuration
param acrSku = 'Standard'

// Storage Configuration
param storageSkuName = 'Standard_GRS'
param enableBlobSoftDelete = true

// Networking
param networkPlugin = 'azure'
param networkPolicy = 'azure'

// Principal for role assignments
param principalId = '00000000-0000-0000-0000-000000000000' // Replace with actual principal ID
param principalType = 'ServicePrincipal'
