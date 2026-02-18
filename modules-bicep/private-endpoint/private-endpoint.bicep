// Opinionated private endpoint module following Acestus standards

metadata name = 'Acestus Private Endpoint'
metadata description = 'Private Endpoint module with Acestus networking standards'
metadata version = '1.0.0'

@description('Name of the private endpoint')
param name string

@description('Location for the private endpoint')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Subnet resource ID where the private endpoint will be created')
param subnetId string

@description('Resource ID of the resource to connect to')
param privateLinkServiceId string

@description('Group IDs (subresources) to connect to')
param groupIds array

@description('Custom network interface name')
param customNetworkInterfaceName string = ''

@description('Private DNS zone group configuration')
param privateDnsZoneGroup object = {}

@description('Manual approval required')
param manualApprovalRequired bool = false

@description('Request message for manual approval')
param requestMessage string = ''

@description('IP configurations for the private endpoint')
param ipConfigurations array = []

@description('Application security groups to associate')
param applicationSecurityGroups array = []

// Build private link service connection
var privateLinkServiceConnection = manualApprovalRequired ? null : {
  name: '${name}-connection'
  properties: {
    privateLinkServiceId: privateLinkServiceId
    groupIds: groupIds
  }
}

// Build manual private link service connection
var manualPrivateLinkServiceConnection = manualApprovalRequired ? {
  name: '${name}-connection'
  properties: {
    privateLinkServiceId: privateLinkServiceId
    groupIds: groupIds
    requestMessage: requestMessage
  }
} : null

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: !empty(customNetworkInterfaceName) ? customNetworkInterfaceName : null
    privateLinkServiceConnections: privateLinkServiceConnection != null ? [privateLinkServiceConnection] : []
    manualPrivateLinkServiceConnections: manualPrivateLinkServiceConnection != null ? [manualPrivateLinkServiceConnection] : []
    ipConfigurations: [for config in ipConfigurations: {
      name: config.name
      properties: {
        groupId: config.groupId
        memberName: config.memberName
        privateIPAddress: config.privateIPAddress
      }
    }]
    applicationSecurityGroups: [for asg in applicationSecurityGroups: {
      id: asg
    }]
  }
}

// Private DNS zone group
resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = if (!empty(privateDnsZoneGroup)) {
  parent: privateEndpoint
  name: privateDnsZoneGroup.?name ?? 'default'
  properties: {
    privateDnsZoneConfigs: [for zone in (privateDnsZoneGroup.?privateDnsZoneIds ?? []): {
      name: replace(split(zone, '/')[8], '.', '-')
      properties: {
        privateDnsZoneId: zone
      }
    }]
  }
}

@description('The resource ID of the private endpoint')
output resourceId string = privateEndpoint.id

@description('The name of the private endpoint')
output name string = privateEndpoint.name

@description('The network interface resource ID')
output networkInterfaceId string = privateEndpoint.properties.networkInterfaces[0].id

@description('The custom DNS configurations')
output customDnsConfigs array = privateEndpoint.properties.customDnsConfigs
