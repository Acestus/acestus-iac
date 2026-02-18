// Example template demonstrating the usage of custom Acestus storage account module
// This shows how to migrate from direct AVM usage to custom ACR modules

param location string = resourceGroup().location
param projectName string
param environment string
param locationCode string
param instanceNumber string
param allowedIP string

@description('Tags for all resources')
param tags object = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  Environment: environment
  Project: projectName
}

// Generate names following Acestus conventions
var storageAccountName = 'st${projectName}${environment}${locationCode}${instanceNumber}'

// Example 1: Basic storage account using custom module
module basicStorage 'br:acracemgtcrprdwus3001.azurecr.io/bicep/modules/storage-account:v1.0.0' = {
  name: 'basicStorage'
  params: {
    storageAccountName: storageAccountName
    location: location
    tags: tags
    skuName: 'Standard_ZRS'
    allowedIpRules: [allowedIP]
    // All other security defaults applied by the module
  }
}

// Example 2: Function App storage with specific containers
module functionStorage 'br:acracemgtcrprdwus3001.azurecr.io/bicep/modules/storage-account:v1.0.0' = {
  name: 'functionStorage'
  params: {
    storageAccountName: 'stfunc${projectName}${environment}${locationCode}${instanceNumber}'
    location: location
    tags: tags
    skuName: 'Standard_LRS'
    allowedIpRules: [allowedIP]
    blobContainers: [
      {
        name: 'azure-webjobs-hosts'
        publicAccess: 'None'
      }
      {
        name: 'azure-webjobs-secrets'
        publicAccess: 'None'
      }
    ]
    // Security settings handled by module
  }
}

// Example 3: Secure storage with customer managed keys (requires additional setup)
/*
module secureStorage 'br:acracemgtcrprdwus3001.azurecr.io/bicep/modules/storage-account:v1.0.0' = {
  name: 'secureStorage'
  params: {
    storageAccountName: 'stsec${projectName}${environment}${locationCode}${instanceNumber}'
    location: location
    tags: tags
    skuName: 'Premium_ZRS'
    allowedIpRules: [allowedIP]
    customerManagedKey: {
      keyName: 'storage-encryption-key'
      keyVaultResourceId: keyVault.outputs.resourceId
      userAssignedIdentityResourceId: managedIdentity.outputs.resourceId
    }
    managedIdentities: {
      userAssignedResourceIds: [managedIdentity.outputs.resourceId]
    }
  }
}
*/

// Outputs
output basicStorageAccountName string = basicStorage.outputs.name
output basicStorageAccountId string = basicStorage.outputs.resourceId
output functionStorageAccountName string = functionStorage.outputs.name
output functionStorageConnectionString string = functionStorage.outputs.connectionString

// Compare the simplified syntax above with the equivalent AVM direct usage:
/*
// OLD WAY: Direct AVM usage (verbose, security settings manual)
module storageAccountOldWay 'br/public:avm/res/storage/storage-account:0.31.0' = {
  name: storageName
  params: {
    name: storageName
    location: location
    skuName: 'Standard_ZRS'
    defaultToOAuthAuthentication: false
    allowSharedKeyAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: [
        {
          action: 'Allow'
          value: allowedIP
        }
      ]
    }
    blobServices: {
      deleteRetentionPolicy: {
        enabled: true
        allowPermanentDelete: false
        days: 30
      }
      automaticSnapshotPolicyEnabled: false
      containerDeleteRetentionPolicy: {
        enabled: true
        allowPermanentDelete: false
        days: 30
      }
      lastAccessTimeTrackingPolicy: {
        enable: true
        name: 'AccessTimeTracking' 
        trackingGranularityInDays: 1
      }
      isVersioningEnabled: true
    }
    tags: tags
  }
}
*/
