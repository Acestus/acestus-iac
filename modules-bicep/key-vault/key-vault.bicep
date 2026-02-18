// Opinionated Key Vault module following Acestus standards

metadata name = 'Acestus Key Vault'
metadata description = 'Custom Key Vault module with Acestus defaults'
metadata version = '1.0.0'

@description('Key Vault name')
param name string

@description('Location for the Key Vault')
param location string = resourceGroup().location

@description('Tags to apply to the Key Vault')
param tags object = {}

@description('Key Vault SKU')
@allowed([
  'standard'
  'premium'
])
param sku string = 'standard'

@description('Enable RBAC authorization')
param enableRbacAuthorization bool = true

@description('Enable soft delete')
param enableSoftDelete bool = true

@description('Soft delete retention in days')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

@description('Enable purge protection')
param enablePurgeProtection bool = true

@description('Public network access')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Network ACLs for Key Vault')
param networkAcls object = {
  defaultAction: 'Allow'
  bypass: 'AzureServices'
}

@description('Access policies (if RBAC is disabled)')
param accessPolicies array = []

module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  params: {
    name: name
    location: location
    tags: tags
    sku: sku
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    publicNetworkAccess: publicNetworkAccess
    networkAcls: networkAcls
    accessPolicies: accessPolicies
  }
}

@description('The resource ID of the Key Vault')
output resourceId string = keyVault.outputs.resourceId

@description('The URI of the Key Vault')
output keyVaultUri string = keyVault.outputs.uri

@description('The name of the Key Vault')
output keyVaultName string = keyVault.outputs.name

@description('All outputs from the AVM Key Vault module')
output keyVault object = keyVault.outputs
