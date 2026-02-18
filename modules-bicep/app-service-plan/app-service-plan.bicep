// Opinionated App Service Plan module following Acestus standards

metadata name = 'Acestus App Service Plan'
metadata description = 'Custom App Service Plan module with Acestus defaults'
metadata version = '1.0.0'

@description('App Service Plan name')
param name string

@description('Location for the App Service Plan')
param location string = resourceGroup().location

@description('Tags to apply to the App Service Plan')
param tags object = {}

@description('App Service Plan SKU name')
param skuName string = 'P0v3'

@description('App Service Plan SKU capacity')
param skuCapacity int = 1

@description('App Service Plan kind')
@allowed([
  'app'
  'elastic'
  'functionApp'
  'linux'
  'windows'
])
param kind string = 'functionApp'

@description('Reserve Linux worker (required for Linux plans)')
param reserved bool = false

@description('Zone redundant plan')
param zoneRedundant bool = false

var finalReserved = kind == 'linux' ? true : reserved

module appServicePlan 'br/public:avm/res/web/serverfarm:0.6.0' = {
  params: {
    name: name
    location: location
    tags: tags
    skuName: skuName
    skuCapacity: skuCapacity
    kind: kind
    reserved: finalReserved
    zoneRedundant: zoneRedundant
  }
}

@description('The resource ID of the App Service Plan')
output resourceId string = appServicePlan.outputs.resourceId

@description('The name of the App Service Plan')
output appServicePlanName string = appServicePlan.outputs.name

@description('All outputs from the AVM App Service Plan module')
output appServicePlan object = appServicePlan.outputs
