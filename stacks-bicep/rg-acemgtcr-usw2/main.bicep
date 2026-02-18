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

@description('Resource ID of the existing management user managed identity.')
param managementUmiResourceId string

var acrName = 'acr${projectName}${environment}${CAFLocation}${instanceNumber}'

module containerRegistry 'br/public:avm/res/container-registry/registry:0.10.0' = {
  name: '${deployment().name}-acr'
  params: {
    name: acrName
    location: location
    tags: tags
    acrSku: 'Premium'
    acrAdminUserEnabled: false
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Disabled'
    networkRuleBypassOptions: 'AzureServices'
    anonymousPullEnabled: false
    dataEndpointEnabled: false
    exportPolicyStatus: 'enabled'
    quarantinePolicyStatus: 'disabled'
    trustPolicyStatus: 'disabled'
    retentionPolicyStatus: 'enabled'
    retentionPolicyDays: 30
    azureADAuthenticationAsArmPolicyStatus: 'enabled'
    softDeletePolicyStatus: 'disabled'
    managedIdentities: {
      userAssignedResourceIds: [managementUmiResourceId]
    }
  }
}

@description('The resource ID of the Azure Container Registry.')
output acrResourceId string = containerRegistry.outputs.resourceId

@description('The name of the Azure Container Registry.')
output acrName string = containerRegistry.outputs.name

@description('The login server of the Azure Container Registry.')
output acrLoginServer string = containerRegistry.outputs.loginServer
