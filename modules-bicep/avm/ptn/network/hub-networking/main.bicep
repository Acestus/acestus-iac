// Opinionated Hub Networking module following Acestus standards and security best practices

metadata name = 'Acestus Hub Networking'
metadata description = 'Custom Hub Networking module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Hub Networking name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Hub Networking properties')
param properties object

module hubNetworking 'br:avm/ptn/network/hub-networking:0.5.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Hub Networking')
output resourceId string = hubNetworking.outputs.resourceId

@description('All outputs from the AVM Hub Networking module')
output hubNetworking object = hubNetworking.outputs
