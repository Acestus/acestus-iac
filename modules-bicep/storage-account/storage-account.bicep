// Opinionated storage account module following Acestus standards and security best practices

metadata name = 'Acestus Storage Account'
metadata description = 'Custom storage account module with Acestus security defaults and naming conventions'
metadata version = '1.1.0'

@description('Storage account name (must be globally unique, 3-24 characters, lowercase letters and numbers only). AVM-compatible alias for storageAccountName.')
param name string = ''

@description('Storage account name (legacy parameter - use "name" for AVM compatibility)')
param storageAccountName string = ''

// Resolve the actual name to use (prefer 'name' if provided, fall back to 'storageAccountName')
var resolvedName = !empty(name) ? name : storageAccountName

@description('Location for the storage account')
param location string = resourceGroup().location

@description('Storage account SKU (Standard ZRS only)')
@allowed([
  'Standard_ZRS'
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_ZRS'

@description('Storage account kind')
@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param kind string = 'StorageV2'

@description('Tags to apply to the storage account')
param tags object = {}

@description('IP addresses allowed to access the storage account (CIDR format)')
param allowedIpRules array = ['192.16.122.254']

@description('Virtual network rules for storage account access')
param virtualNetworkRules array = []

@description('Default network access action')
@allowed([
  'Allow'
  'Deny'
])
param defaultNetworkAction string = 'Deny'

@description('Enable soft delete for blobs')
param enableBlobSoftDelete bool = true

@description('Blob soft delete retention period in days')
@minValue(1)
@maxValue(365)
param blobSoftDeleteRetentionDays int = 30

@description('Enable versioning for blobs')
param enableBlobVersioning bool = true

@description('Enable container soft delete')
param enableContainerSoftDelete bool = true

@description('Container soft delete retention period in days')
@minValue(1)
@maxValue(365)
param containerSoftDeleteRetentionDays int = 30

@description('Enable shared key access')
param allowSharedKeyAccess bool = false

@description('Enable blob public access')
param allowBlobPublicAccess bool = false

@description('Minimum TLS version')
@allowed([
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'

@description('Require secure transfer (HTTPS)')
param supportsHttpsTrafficOnly bool = true

@description('Enable infrastructure encryption')
param requireInfrastructureEncryption bool = false

@description('Customer managed key configuration')
param customerManagedKey object = {}

@description('User assigned identities for customer managed key access')
param managedIdentities object = {}

@description('Blob containers to create')
param blobContainers array = []

@description('Queue services configuration')
param queueServices object = {}

@description('Table services configuration')
param tableServices object = {}

@description('File services configuration')
param fileServices object = {}

// Storage Account Resource using AVM
module storageAccount 'br/public:avm/res/storage/storage-account:0.31.0' = {
  name: '${deployment().name}-storage'
  params: {
    name: resolvedName
    location: location
    skuName: skuName
    kind: kind
    tags: tags
    
    // Security Configuration
    allowSharedKeyAccess: allowSharedKeyAccess
    allowBlobPublicAccess: allowBlobPublicAccess
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    requireInfrastructureEncryption: requireInfrastructureEncryption
    defaultToOAuthAuthentication: !allowSharedKeyAccess
    
    // Network Access Control
    publicNetworkAccess: empty(allowedIpRules) && empty(virtualNetworkRules) ? 'Disabled' : 'Enabled'
    networkAcls: {
      defaultAction: defaultNetworkAction
      bypass: 'AzureServices'
      ipRules: [for rule in allowedIpRules: {
        action: 'Allow'
        value: rule
      }]
      virtualNetworkRules: [for rule in virtualNetworkRules: {
        action: 'Allow'
        id: rule
      }]
    }
    
    // Customer Managed Key
    customerManagedKey: !empty(customerManagedKey) ? customerManagedKey : null
    managedIdentities: !empty(managedIdentities) ? managedIdentities : null
    
    // Blob Services Configuration
    blobServices: {
      deleteRetentionPolicy: {
        enabled: enableBlobSoftDelete
        allowPermanentDelete: false
        days: enableBlobSoftDelete ? blobSoftDeleteRetentionDays : null
      }
      containerDeleteRetentionPolicy: {
        enabled: enableContainerSoftDelete
        allowPermanentDelete: false
        days: enableContainerSoftDelete ? containerSoftDeleteRetentionDays : null
      }
      isVersioningEnabled: enableBlobVersioning
      automaticSnapshotPolicyEnabled: false
      lastAccessTimeTrackingPolicy: {
        enable: true
        name: 'AccessTimeTracking'
        trackingGranularityInDays: 1
      }
      containers: blobContainers
    }
    
    // Additional Services
    queueServices: !empty(queueServices) ? queueServices : null
    tableServices: !empty(tableServices) ? tableServices : null
    fileServices: !empty(fileServices) ? fileServices : null
  }
}

// Outputs
@description('The resource ID of the storage account')
output resourceId string = storageAccount.outputs.resourceId

@description('The name of the storage account')
output name string = storageAccount.outputs.name

@description('The primary blob endpoint of the storage account')
output primaryBlobEndpoint string = storageAccount.outputs.primaryBlobEndpoint

@description('The service endpoints of the storage account')
output serviceEndpoints object = storageAccount.outputs.serviceEndpoints

@description('The connection string for the storage account (limited - no access keys exposed)')
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.outputs.name};EndpointSuffix=${environment().suffixes.storage}'
