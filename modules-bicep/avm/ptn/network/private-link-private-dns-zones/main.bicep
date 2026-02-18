// Opinionated Private Link Private DNS Zones module following Acestus standards and security best practices

metadata name = 'Acestus Private Link Private DNS Zones'
metadata description = 'Custom Private Link Private DNS Zones module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Private Link Private DNS Zones name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Private Link Private DNS Zones properties')
param properties object

module privateLinkPrivateDnsZones 'br:avm/ptn/network/private-link-private-dns-zones:0.7.2' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Private Link Private DNS Zones')
output resourceId string = privateLinkPrivateDnsZones.outputs.resourceId

@description('All outputs from the AVM Private Link Private DNS Zones module')
output privateLinkPrivateDnsZones object = privateLinkPrivateDnsZones.outputs
