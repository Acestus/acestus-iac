// Opinionated ALZ Empty module following Acestus standards and security best practices

metadata name = 'Acestus ALZ Empty'
metadata description = 'Custom ALZ Empty module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('ALZ Empty name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Empty properties')
param properties object

module empty 'br:avm/ptn/alz/empty:0.3.6' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Empty')
output resourceId string = empty.outputs.resourceId

@description('All outputs from the AVM Empty module')
output empty object = empty.outputs
