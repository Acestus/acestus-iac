// Opinionated Sub Vending module following Acestus standards and security best practices

metadata name = 'Acestus Sub Vending'
metadata description = 'Custom Sub Vending module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Sub Vending name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Sub Vending properties')
param properties object

module subVending 'br:avm/ptn/lz/sub-vending:0.5.3' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Sub Vending')
output resourceId string = subVending.outputs.resourceId

@description('All outputs from the AVM Sub Vending module')
output subVending object = subVending.outputs
