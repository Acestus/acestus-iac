// Opinionated ACR Container App module following Acestus standards and security best practices

metadata name = 'Acestus ACR Container App'
metadata description = 'Custom ACR Container App module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('ACR Container App name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Container registry resource ID')
param containerRegistryId string

@description('Container app properties')
param properties object

module acrContainerApp 'br:avm/ptn/azd/acr-container-app:0.4.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    containerRegistryId: containerRegistryId
    properties: properties
  }
}

@description('The resource ID of the ACR Container App')
output resourceId string = acrContainerApp.outputs.resourceId

@description('All outputs from the AVM ACR Container App module')
output acrContainerApp object = acrContainerApp.outputs
