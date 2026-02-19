// Opinionated Container Apps Stack module following Acestus standards and security best practices

metadata name = 'Acestus Container Apps Stack'
metadata description = 'Custom Container Apps Stack module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Container Apps Stack name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Container Apps Stack properties')
param properties object

module containerAppsStack 'br:avm/ptn/azd/container-apps-stack:0.3.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Container Apps Stack')
output resourceId string = containerAppsStack.outputs.resourceId

@description('All outputs from the AVM Container Apps Stack module')
output containerAppsStack object = containerAppsStack.outputs
