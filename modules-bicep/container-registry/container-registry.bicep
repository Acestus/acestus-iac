// Opinionated container registry module following Acestus standards

metadata name = 'Acestus Container Registry'
metadata description = 'Azure Container Registry module with Acestus security defaults'
metadata version = '1.1.0'

@description('Name of the container registry (must be globally unique, 5-50 alphanumeric characters)')
@minLength(5)
@maxLength(50)
param name string

@description('Location for the container registry')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

// SKU parameters - support both wrapper style and AVM style
@description('SKU for the container registry (legacy parameter - use acrSku for AVM compatibility). Leave empty to use acrSku.')
param sku string = ''

@description('SKU for the container registry (AVM-compatible parameter)')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

// Resolve SKU - prefer explicit sku if provided, otherwise use acrSku
var resolvedSku = !empty(sku) ? sku : acrSku

// Admin user parameters - support both styles
@description('Enable admin user for the registry (legacy parameter)')
param adminUserEnabled bool = false

@description('Enable admin user for the registry (AVM-compatible parameter)')
param acrAdminUserEnabled bool = false

// Resolve admin user setting
var resolvedAdminUserEnabled = adminUserEnabled || acrAdminUserEnabled

@description('Enable public network access')
param publicNetworkAccess string = 'Disabled'

@description('Enable zone redundancy (Premium SKU only)')
param zoneRedundancy string = 'Disabled'

@description('Enable data endpoint (Premium SKU only)')
param dataEndpointEnabled bool = false

@description('Network rule bypass options')
@allowed([
  'AzureServices'
  'None'
])
param networkRuleBypassOptions string = 'AzureServices'

@description('Enable anonymous pull access')
param anonymousPullEnabled bool = false

// Retention policy parameters - support both styles
@description('Retention policy for untagged manifests (Premium SKU only)')
param retentionPolicyDays int = 30

@description('Enable retention policy (legacy parameter)')
param retentionPolicyEnabled bool = true

@description('Retention policy status (AVM-compatible parameter). Leave empty to use retentionPolicyEnabled.')
param retentionPolicyStatus string = ''

// Resolve retention policy status
var resolvedRetentionPolicyStatus = !empty(retentionPolicyStatus) ? retentionPolicyStatus : (retentionPolicyEnabled ? 'enabled' : 'disabled')

// Soft delete parameters - support both styles
@description('Soft delete retention days (Premium SKU only)')
param softDeletePolicyDays int = 7

@description('Enable soft delete policy (legacy parameter)')
param softDeletePolicyEnabled bool = true

@description('Soft delete policy status (AVM-compatible parameter). Leave empty to use softDeletePolicyEnabled.')
param softDeletePolicyStatus string = ''

// Resolve soft delete status
var resolvedSoftDeletePolicyStatus = !empty(softDeletePolicyStatus) ? softDeletePolicyStatus : (softDeletePolicyEnabled ? 'enabled' : 'disabled')

// Additional AVM-compatible policy parameters
@description('Export policy status (AVM-compatible)')
@allowed([
  'enabled'
  'disabled'
])
param exportPolicyStatus string = 'enabled'

@description('Quarantine policy status (AVM-compatible)')
@allowed([
  'enabled'
  'disabled'
])
param quarantinePolicyStatus string = 'disabled'

@description('Trust policy status (AVM-compatible)')
@allowed([
  'enabled'
  'disabled'
])
param trustPolicyStatus string = 'disabled'

@description('Azure AD authentication as ARM policy status (AVM-compatible)')
@allowed([
  'enabled'
  'disabled'
])
param azureADAuthenticationAsArmPolicyStatus string = 'enabled'

@description('User assigned identities')
param managedIdentities object = {}

module containerRegistry 'br/public:avm/res/container-registry/registry:0.10.0' = {
  name: '${deployment().name}-acr'
  params: {
    name: name
    location: location
    tags: tags
    acrSku: resolvedSku
    acrAdminUserEnabled: resolvedAdminUserEnabled
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
    networkRuleBypassOptions: networkRuleBypassOptions
    anonymousPullEnabled: anonymousPullEnabled
    dataEndpointEnabled: dataEndpointEnabled
    exportPolicyStatus: exportPolicyStatus
    quarantinePolicyStatus: quarantinePolicyStatus
    trustPolicyStatus: trustPolicyStatus
    retentionPolicyStatus: resolvedRetentionPolicyStatus
    retentionPolicyDays: retentionPolicyDays
    azureADAuthenticationAsArmPolicyStatus: azureADAuthenticationAsArmPolicyStatus
    softDeletePolicyStatus: resolvedSoftDeletePolicyStatus
    softDeletePolicyDays: softDeletePolicyDays
    managedIdentities: !empty(managedIdentities) ? managedIdentities : null
  }
}

@description('The resource ID of the container registry')
output resourceId string = containerRegistry.outputs.resourceId

@description('The name of the container registry')
output name string = containerRegistry.outputs.name

@description('The login server URL')
output loginServer string = containerRegistry.outputs.loginServer

@description('The principal ID of the system assigned identity')
output systemAssignedMIPrincipalId string = containerRegistry.outputs.?systemAssignedMIPrincipalId ?? ''
