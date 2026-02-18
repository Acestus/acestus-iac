// Opinionated ALZ AMA module following Acestus standards and security best practices

metadata name = 'Acestus ALZ AMA'
metadata description = 'Custom ALZ AMA module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('ALZ AMA name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('AMA properties')
param properties object

module ama 'br:avm/ptn/alz/ama:0.1.1' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the AMA')
output resourceId string = ama.outputs.resourceId

@description('All outputs from the AVM AMA module')
output ama object = ama.outputs
