// VNet Subnet Additions Bicep template
targetScope = 'resourceGroup'

// ==================================
// Parameters
// ==================================

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the existing VNet.')
param vnetName string = 'vnet-transit-conn-weu-001'

@description('Tags to be applied to all resources.')
param tags object = {}

// ==================================
// Variables
// ==================================

var commonTags = union(tags, {
  ManagedBy: 'Bicep'
})

// ==================================
// Resources
// ==================================

// Reference existing VNet
resource existingVNet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: vnetName
}

// App Service Integration Subnet
resource appServiceIntegrationSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: 'snet-app-integration-weu'
  parent: existingVNet
  properties: {
    addressPrefix: '10.65.64.0/27'  // 32 addresses for App Service integration
    delegations: [
      {
        name: 'Microsoft.Web.serverFarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

// Private Endpoints Subnet
resource privateEndpointsSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: 'snet-private-endpoints-weu'
  parent: existingVNet
  properties: {
    addressPrefix: '10.65.65.0/27'  // 32 addresses for private endpoints
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    appServiceIntegrationSubnet
  ]
}

// ==================================
// Outputs
// ==================================

@description('The resource ID of the App Service integration subnet.')
output appServiceIntegrationSubnetResourceId string = appServiceIntegrationSubnet.id

@description('The resource ID of the private endpoints subnet.')
output privateEndpointsSubnetResourceId string = privateEndpointsSubnet.id

@description('The address prefix of the App Service integration subnet.')
output appServiceIntegrationSubnetAddressPrefix string = appServiceIntegrationSubnet.properties.addressPrefix

@description('The address prefix of the private endpoints subnet.')
output privateEndpointsSubnetAddressPrefix string = privateEndpointsSubnet.properties.addressPrefix
