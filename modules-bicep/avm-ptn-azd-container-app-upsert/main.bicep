// Opinionated Container App Upsert module following Acestus standards and security best practices

metadata name = 'Acestus Container App Upsert'
metadata description = 'Custom Container App Upsert module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Container App Upsert name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Container App Upsert properties')
param properties object

module containerAppUpsert 'br:avm/ptn/azd/container-app-upsert:0.3.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Container App Upsert')
output resourceId string = containerAppUpsert.outputs.resourceId

@description('All outputs from the AVM Container App Upsert module')
output containerAppUpsert object = containerAppUpsert.outputs
