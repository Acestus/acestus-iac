targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the project, used for naming resources.')
param projectName string

@description('The environment name, used for naming resources.')
param environment string

@description('The Cloud Adoption Framework location, used for naming resources.')
param CAFLocation string

@description('The instance number, used for naming resources.')
param instanceNumber string

@description('Tags to be applied to all resources.')
param tags object = {}

var keyVaultName = 'kv-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'

module keyVault 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/key-vault:v1.1.0' = {
  name: '${deployment().name}-kv'
  params: {
    name: keyVaultName
    location: location
    tags: tags
    sku: 'standard'
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    accessPolicies: []
  }
}

@description('The resource ID of the Key Vault.')
output keyVaultResourceId string = keyVault.outputs.resourceId

@description('The URI of the Key Vault.')
output keyVaultUri string = keyVault.outputs.uri

@description('The name of the Key Vault.')
output keyVaultName string = keyVault.outputs.name
